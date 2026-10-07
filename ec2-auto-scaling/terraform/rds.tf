resource "aws_db_subnet_group" "this" {
  name        = "fcaj-subnet-group"
  description = "Subnet Group for DB Instance"

  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier = "fcaj-db-instance"

  # Storage
  allocated_storage = 20
  storage_type      = "gp3"

  # Database
  engine         = "mysql"
  engine_version = "8.0"
  db_name        = "fcaj"

  # Instance
  instance_class = "db.m5.large"

  # Credentials
  username = "admin"
  password = var.db_password

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Multi-AZ
  multi_az = true

  # Parameter group
  parameter_group_name = "default.mysql8.0"

  # Backup
  backup_retention_period = 7

  # Lab cleanup
  skip_final_snapshot = true
}