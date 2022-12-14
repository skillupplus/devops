terraform {
  required_version = ">= 1.3.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

  backend "s3" {
    bucket  = "skillup-terraform-remote-state"
    key     = "production/containers/eks/terraform.state"
    region  = "ap-northeast-2"
    profile = "skillup"
  }
}

provider "aws" {
  profile = "skillup"
  region  = "ap-northeast-2"
}
