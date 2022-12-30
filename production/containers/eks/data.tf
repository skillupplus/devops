data "terraform_remote_state" "production_vpc" {
  backend = "s3"

  config = {
    bucket  = "skillup-terraform-remote-state"
    key     = "production/vpc/terraform.state"
    region  = "ap-northeast-2"
    profile = "skillup"
  }
}
