################################################################################
# Remote State
################################################################################

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

################################################################################
# Reference Data
################################################################################

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

################################################################################
# Reference Policy
################################################################################

data "aws_iam_policy_document" "assume_role_policy_cluster" {
  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_node_group" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}
