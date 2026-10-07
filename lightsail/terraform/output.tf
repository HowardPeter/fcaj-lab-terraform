output "static_ip_address" {
  value = aws_lightsail_static_ip.main.ip_address
}

output "db_endpoint" {
  value = aws_lightsail_database.main.master_endpoint_address
}