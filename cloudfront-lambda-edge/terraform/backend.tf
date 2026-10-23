terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.49"
    }
    # provider của terraform, dùng để arcive file lambda
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
  backend "s3" {
    bucket = "fcaj-lab-tf-state-430118860011-ap-southeast-1-an"
    key    = "cloudfront-lambda-edge/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# Region phụ cho S3 bucket failover của Origin Group
provider "aws" {
  alias  = "secondary"
  region = "ap-southeast-2"
}

# Lambda@Edge bắt buộc tạo ở us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}