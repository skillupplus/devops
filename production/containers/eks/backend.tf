terraform {
  backend "s3" {
    bucket  = "skillup-terraform-remote-state"
    key     = "production/containers/eks/terraform.state"
    region  = "ap-northeast-2"
    profile = "skillup"
  }
}
