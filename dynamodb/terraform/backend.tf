terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.49"
    }
  }
  backend "s3" {
    bucket = "fcaj-lab-tf-state-430118860011-ap-southeast-1-an"
    key    = "dynamodb/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}