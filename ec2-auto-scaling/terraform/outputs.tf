output "alb" {
  value = {
    dns_name = aws_lb.this.dns_name
    port     = aws_lb.this.port
  }
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}