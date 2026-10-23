data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "allviewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_response_headers_policy" "security_header" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "Cloudfront-S3-OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true

  default_root_object = "index.html"

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/error.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 504
    response_code         = 200
    response_page_path    = "/error.html"
    error_caching_min_ttl = 5
  }

  origin {
    origin_id                = "s3-${aws_s3_bucket.site.id}"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  origin {
    origin_id                = "failover-s3-${aws_s3_bucket.site_2.id}"
    domain_name              = aws_s3_bucket.site_2.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  origin {
    origin_id   = "ec2-${aws_instance.main.id}"
    domain_name = aws_instance.main.public_dns

    custom_origin_config {
      http_port  = 80
      https_port = 443

      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]

      origin_keepalive_timeout = 60
    }
  }

  origin_group {
    origin_id = "OriginGroup-cloudfrontlab-s3Bucket"

    failover_criteria {
      status_codes = [403, 404]
    }

    member {
      origin_id = "s3-${aws_s3_bucket.site.id}"
    }

    member {
      origin_id = "failover-s3-${aws_s3_bucket.site_2.id}"
    }
  }

  default_cache_behavior {
    target_origin_id = "OriginGroup-cloudfrontlab-s3Bucket"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_header.id
    viewer_protocol_policy     = "redirect-to-https"

    compress = true
  }

  ordered_cache_behavior {
    path_pattern     = "/api"
    target_origin_id = "ec2-${aws_instance.main.id}"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.allviewer.id
    viewer_protocol_policy   = "redirect-to-https"

    compress = true
  }

  ordered_cache_behavior {
    path_pattern     = "/serverless"
    target_origin_id = "ec2-${aws_instance.main.id}"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.allviewer.id
    viewer_protocol_policy   = "redirect-to-https"

    compress = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.edge.qualified_arn # ARN kèm version
      include_body = false
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}