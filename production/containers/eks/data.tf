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
