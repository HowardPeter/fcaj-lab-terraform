output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "s3_object_url" {
  value = "https://${aws_s3_bucket.site.bucket_regional_domain_name}/${aws_s3_object.index.key}"
}