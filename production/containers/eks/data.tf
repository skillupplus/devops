data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = "skillup-terraform-remote-state"
    key     = "production/vpc/terraform.state"
    region  = "ap-northeast-2"
    profile = "skillup"
  }
}

data "aws_kms_key" "this" {
  key_id = "alias/skillup-key"
}
