data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  # dùng bản AL2023 mới nhất phù hợp filter mỗi khi apply
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# script cài đặt chạy khi instance boot lần đầu (dùng trong launch template)
locals {
  user_data = templatefile("${path.module}/setup.sh", {
    db_host     = aws_db_instance.main.address
    db_name     = "fcaj"
    db_user     = "admin"
    db_password = var.db_password
  })
}

resource "aws_key_pair" "main" {
  key_name   = "fcaj-key"
  public_key = file("~/.ssh/ec2-lab-key.pub")
}

# TẠO LAUNCH TEMPLATE VÀ AUTO SCALING GROUP
# Cách 1: launch template chạy thẳng từ AMI AL2023 gốc + user_data.
# Mỗi instance mới tự chạy setup.sh khi boot -> không phụ thuộc AMI tự tạo,
# đổi lại mất ~3-5 phút cài đặt trước khi app lên cổng 5000.
resource "aws_launch_template" "app" {
  name                   = "fcaj-template"
  description            = "Template for fcaj app (AL2023 + user_data)"
  update_default_version = true

  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.main.key_name

  # launch template bắt buộc user_data dạng base64 (khác với aws_instance)
  user_data = base64encode(local.user_data)

  # chỉ khai báo security group ở network interface, không khai báo thêm
  # vpc_security_group_ids (AWS từ chối RunInstances nếu có cả hai)
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
    delete_on_termination       = true
  }

  # cấu hình volume/disk của instance
  block_device_mappings {
    device_name = data.aws_ami.amazon_linux_2023.root_device_name

    ebs {
      volume_size           = 10
      volume_type           = "gp3"
      encrypted             = true # mã hóa bằng KMS
      delete_on_termination = true # xóa khi instance bị xóa
    }
  }

  # cấu hình lấy IMDS (metadata từ endpoint nội bộ aws)
  metadata_options {
    http_endpoint               = "enabled"  # cho phép ec2 đọc metadata
    http_tokens                 = "required" # phải có token mới gọi được (IMDSv2)
    http_put_response_hop_limit = 1          # số lớp network có thể đi qua
    instance_metadata_tags      = "enabled"  # cho phép đọc tag của ec2 từ bên trong máy
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "fcaj-asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "fcaj-asg"
  vpc_zone_identifier = aws_subnet.public[*].id

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  target_group_arns = [aws_lb_target_group.this.arn]

  # dùng health check của ALB để thay instance nếu app không lên được.
  # grace period phải dài hơn thời gian chạy setup.sh, nếu không ASG sẽ
  # terminate instance trước khi cài xong rồi tạo lại liên tục
  health_check_type         = "ELB"
  health_check_grace_period = 400

  # "Enable group metrics collection within CloudWatch" như lab
  # (bỏ các metric WarmPool* vì lab không dùng warm pool)
  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTotalCapacity",
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # đổi launch template (vd: sửa setup.sh) -> tự thay dần các instance cũ
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # manual scaling: đổi desired capacity trên console mà apply lại không bị ghi đè
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# ---------------------------------------------------------------------------
# Cách 2: tạo AMI từ instance SAU KHI setup.sh chạy xong.
#
# Lỗi ban đầu: aws_ami_from_instance mặc định reboot instance để snapshot, và
# nó chạy ngay khi instance vừa "running" -> setup.sh bị ngắt giữa chừng,
# cloud-init không chạy lại user_data sau reboot -> app không bao giờ lên,
# AMI cũng chụp lại trạng thái cài dở.
#
# Cách sửa: chèn bước terraform_data SSH vào instance và chờ
# `cloud-init status --wait` (trả lỗi nếu setup.sh fail -> dừng apply, không
# tạo AMI hỏng). Sau đó mới tạo AMI, và launch template dùng AMI này, không
# cần user_data -> instance mới boot ~1-2 phút là app chạy (pm2 + systemd).
#
# Yêu cầu khi dùng:
#   - máy chạy terraform SSH được tới instance: IP đúng với var.my_ip (rule
#     cổng 22) và có private key ~/.ssh/ec2-lab-key
#   - setup.sh phải đăng ký pm2 startup đúng user (-u root --hp /root), vì app
#     phải tự chạy lại sau reboot khi tạo AMI và trên instance từ AMI
#   - apply lâu hơn (~3-5 phút chờ setup + ~3-10 phút tạo AMI)
#   - instance nguồn aws_instance.main chạy song song với ASG (tốn thêm 1 EC2)
#
# Cách chuyển sang cách 2:
#   1. bỏ comment 3 resource aws_instance.main, terraform_data.wait_setup và
#      aws_ami_from_instance.this
#   2. trong aws_launch_template.app ở trên: đổi image_id thành
#      aws_ami_from_instance.this.id và xóa dòng user_data
#   3. có thể giảm health_check_grace_period của ASG xuống ~120
# ---------------------------------------------------------------------------

# # instance nguồn: chạy setup.sh một lần để làm "golden image"
# resource "aws_instance" "main" {
#   ami           = data.aws_ami.amazon_linux_2023.id
#   instance_type = "t3.micro"
#
#   # networking
#   subnet_id                   = aws_subnet.public[1].id
#   vpc_security_group_ids      = [aws_security_group.ec2.id]
#   associate_public_ip_address = true
#
#   key_name = aws_key_pair.main.key_name
#
#   # chạy script khi khởi tạo lần đầu
#   user_data = local.user_data
#   # sửa setup.sh -> tạo lại instance (và AMI), nếu không AMI sẽ bị cũ
#   user_data_replace_on_change = true
#
#   # cấu hình volume/disk của instance
#   root_block_device {
#     volume_size           = 10
#     volume_type           = "gp3"
#     encrypted             = true # mã hóa bằng KMS
#     delete_on_termination = true # xóa khi instance bị xóa
#   }
#
#   # cấu hình lấy IMDS (metadata từ endpoint nội bộ aws)
#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#     instance_metadata_tags      = "enabled"
#   }
# }
#

# resource "terraform_data" "wait_setup" {
#   # instance bị thay -> chờ lại
#   triggers_replace = aws_instance.main.id
#
#   connection {
#     type        = "ssh"
#     host        = aws_instance.main.public_ip
#     user        = "ec2-user"
#     private_key = file("~/.ssh/ec2-lab-key")
#     timeout     = "5m"
#   }
#
#   provisioner "remote-exec" {
#     # chờ cloud-init (setup.sh) chạy xong, trả lỗi nếu setup.sh fail
#     inline = ["sudo cloud-init status --wait"]
#   }
# }
#
# resource "aws_ami_from_instance" "this" {
#   name               = "fcaj-ami"
#   source_instance_id = aws_instance.main.id
#
#   # chỉ tạo AMI khi setup.sh đã xong
#   depends_on = [terraform_data.wait_setup]
# }
