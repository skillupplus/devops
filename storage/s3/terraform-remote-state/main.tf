terraform {
  required_version = ">= 1.3.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

  # backend "s3" {
  #   bucket = "skillup-terraform-remote-state"
  #   key    = "storage/s3/terraform-remote-state/terraform.tfstate"
  #   region = "ap-northeast-2"
  # }
}

provider "aws" {
  profile = "skillup"
  region  = "ap-northeast-2"
}

resource "aws_s3_bucket" "this" {
  bucket = "skillup-terraform-remote-state"
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled"
  }
}

# data "aws_iam_policy_document" "full_access_to_devops" {
#   statement {
#     principals {
#       type = ""
#     }
#   }
# }
