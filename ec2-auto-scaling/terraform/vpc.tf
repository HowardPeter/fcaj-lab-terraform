# Lấy danh sách AZ khả dụng của region hiện tại
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC CHÍNH
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # Bật hỗ trợ DNS bên trong VPC
  enable_dns_hostnames = true # Cho phép tạo hostname cho instance trong VPC

  tags = {
    Name = "AutoScaling-lab"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# PUBLIC SUBNETS
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets) # Tạo nhiều subnet tùy theo số CIDR trong danh sách
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]                          # Tham chiếu đến CIDR tương ứng trong mảng cho từng subnet
  map_public_ip_on_launch = true                                                     # Tự động gán IP public khi tạo EC2 (cho Public Subnet ra IGW)
  availability_zone       = data.aws_availability_zones.available.names[count.index] # Mỗi subnet ở 1 AZ khác nhau
}

# PRIVATE SUBNETS
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Route Table cho public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"                 # Mọi traffic ra ngoài
    gateway_id = aws_internet_gateway.igw.id # Thông qua Internet Gateway
  }
}

# Route Table cho private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

# Gắn tất cả public subnet với route table public
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Gắn tất cả private subnet với route table private
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
