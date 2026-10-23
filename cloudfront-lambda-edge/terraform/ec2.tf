data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

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

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "main" {
  key_name   = "cloudfront-lab-key"
  public_key = file("~/.ssh/ec2-lab-key.pub")
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  key_name                    = aws_key_pair.main.key_name
  user_data                   = file("${path.module}/setup.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name = "CloudFront-Server"
  }
}
