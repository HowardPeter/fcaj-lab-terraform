output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "ec2_public_ip" {
  value = aws_instance.main.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.main.public_dns
}

output "serverless_url" {
  value = "https://${aws_cloudfront_distribution.main.domain_name}/serverless"
}