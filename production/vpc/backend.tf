terraform {
  backend "s3" {
    bucket  = "skillup-terraform-remote-state"
    key     = "production/vpc/terraform.state"
    region  = "ap-northeast-2"
    profile = "skillup"
  }
}
