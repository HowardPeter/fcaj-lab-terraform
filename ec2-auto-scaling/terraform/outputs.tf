output "DNS_Name" {
  value       = aws_lb.this.dns_name
}

output "Instance_IPv4" {
  value = aws_instance.main.public_ip
}