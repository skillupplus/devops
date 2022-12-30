################################################################################
# Local
################################################################################

locals {
  tag = {
    ProjectName = var.name
    Domain      = "eks"
    ManagedBy   = "terraform"
  }
}

################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "this" {
  name               = "${var.name}-eks-role"
  description        = "EKS Cluster iam role"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
POLICY
}

resource "aws_iam_role_policy_attachment" "this_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.this.name
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "this" {
  vpc_id = data.terraform_remote_state.production_vpc.outputs.production_vpc_id
  name   = "${var.cluster_name}-sg"

  tags = merge(
    {
      Name = "${var.cluster_name}-sg"
    },
    local.tag
  )
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# Cluster
################################################################################

# resource "aws_eks_cluster" "this" {
#   name     = var.cluster_name
#   role_arn = aws_iam_role.this.arn
#   version  = var.cluster_version

#   vpc_config {

#   }
# }
