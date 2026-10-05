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

resource "aws_key_pair" "main" {
  key_name   = "kp-linux"
  public_key = file("~/.ssh/ec2-lab-key.pub")
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  # networking
  subnet_id                   = aws_subnet.public[1].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.main.key_name

  # chạy script khi khởi tạo lần đầu
  user_data = templatefile("${path.module}/setup.sh", {
    db_host     = aws_db_instance.main.address
    db_name     = "fcaj"
    db_user     = "admin"
    db_password = var.db_password
  })

  # cấu hình volume/disk của instane
  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true # mã hóa bằng KMS
    delete_on_termination = true # xóa khi instance bị xóa
  }

  # cấu hình lấy IMDS (metadata từ endpoint nội bộ aws)
  metadata_options {
    http_endpoint               = "enabled"  # cho phép ec2 đọc metadata
    http_tokens                 = "required" # phải có token mới gọi được
    http_put_response_hop_limit = 1          # số lớp network có thể đi qua
    instance_metadata_tags      = "enabled"  # cho phép đọc tag của ec2 từ bên trong máy
  }
}
