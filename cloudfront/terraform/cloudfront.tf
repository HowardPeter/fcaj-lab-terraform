data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# Tạo OAC, cơ chế xác thực để CloudFront truy cập S3 origin một cách an toàn.
resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "ws94-s3-oac"
  description                       = "OAC for S3 origin of CloudFront"
  origin_access_control_origin_type = "s3"     # loại origin mà OAC bảo vệ
  signing_behavior                  = "always" # luôn ký request gửi đến S3 bằng thông tin xác thực AWS
  signing_protocol                  = "sigv4"  # sử dụng AWS Signature Version 4 (SigV4).
}

# NOTE: CloudFront mặc định pricing Pay-as-you-go, muốn để Free plan cần chỉnh trên console, terraform không có config này
# Tạo cloudfront distribution
resource "aws_cloudfront_distribution" "site" {
  enabled             = true # bật distribution để bắt đầu phục vụ request
  comment             = "WS94-Cloudfront"
  default_root_object = "index.html" # object mặc định khi người dùng truy cập đường dẫn gốc "/".

  # Origin: S3 bucket chứa nội dung website
  origin {
    origin_id = "s3-${aws_s3_bucket.site.id}"

    # domain endpoint theo region của S3 bucket
    # Vd: doc-example-bucket.s3.ap-southeast-1.amazonaws.com
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  # Quy tắc xử lý request mặc định
  default_cache_behavior {
    target_origin_id       = "s3-${aws_s3_bucket.site.id}"
    viewer_protocol_policy = "redirect-to-https" # nếu người dùng truy cập bằng HTTP, redirect sang HTTPS
    allowed_methods        = ["GET", "HEAD"]     # chỉ cho phép đọc nội dung bằng GET và HEAD
    cached_methods         = ["GET", "HEAD"]     # chỉ cache response của GET và HEAD
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress               = true # cho phép CloudFront tự động nén nội dung phù hợp
  }

  # thiết lập giới hạn
  restrictions {
    # giới hạn theo vùng lãnh thổ
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Dùng domain mặc định *.cloudfront.net, không cấu hình CNAME
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
