data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Chỉ cho phép CloudFront distribution của lab đọc object (OAC)
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = ["${aws_s3_bucket.site.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket" "site" {
  bucket = format(
    "cf-lab-%s-%s-an",
    data.aws_caller_identity.current.account_id,
    data.aws_region.current.region
  )

  bucket_namespace = "account-regional"

  # Bucket bật versioning, cho phép destroy luôn mọi phiên bản object
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/../web/index.html"
  content_type = "text/html"

  # theo dõi và phát hiện thay đổi nội dung file để cập nhật
  etag = filemd5("${path.module}/../web/index.html")
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.site.id
  key          = "error.html"
  source       = "${path.module}/../web/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../web/error.html")
}

# ---
# Secondary bucket
data "aws_region" "secondary" {
  provider = aws.secondary
}

data "aws_iam_policy_document" "bucket_policy_secondary" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = ["${aws_s3_bucket.site_2.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket" "site_2" {
  provider = aws.secondary

  bucket = format(
    "cflab-secondary-%s-%s-an",
    data.aws_caller_identity.current.account_id,
    data.aws_region.secondary.region
  )

  bucket_namespace = "account-regional"

  # Bucket bật versioning, cho phép destroy luôn mọi phiên bản object
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "site_2" {
  provider = aws.secondary

  bucket = aws_s3_bucket.site_2.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site_2" {
  provider = aws.secondary

  bucket = aws_s3_bucket.site_2.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site_2" {
  provider = aws.secondary

  bucket = aws_s3_bucket.site_2.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "site_2" {
  provider = aws.secondary

  bucket = aws_s3_bucket.site_2.id
  policy = data.aws_iam_policy_document.bucket_policy_secondary.json

  depends_on = [aws_s3_bucket_public_access_block.site_2]
}

resource "aws_s3_object" "secondary_index" {
  provider = aws.secondary

  bucket       = aws_s3_bucket.site_2.id
  key          = "secondary-index.html"
  source       = "${path.module}/../web/secondary-index.html"
  content_type = "text/html"

  # theo dõi và phát hiện thay đổi nội dung file để cập nhật
  etag = filemd5("${path.module}/../web/secondary-index.html")
}
