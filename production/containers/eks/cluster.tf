################################################################################
# IAM Role
################################################################################

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-eks-role"
  description        = "EKS Cluster iam role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = merge({
    Name = "${var.name}-eks-role"
    },
    local.tag
  )
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.this.name
}

################################################################################
# Security Groups
################################################################################

locals {
  cluster_security_group_id = aws_security_group.cluster.id
}
resource "aws_security_group" "cluster" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  name = "${var.cluster_name}-cluster"

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster"
    },
    local.tag
  )
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.cluster.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.this.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = concat(
      data.terraform_remote_state.vpc.outputs.public_subnet_ids,
      data.terraform_remote_state.vpc.outputs.private_subnet_ids
    )
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "192.168.0.0/16"
  }

  encryption_config {
    provider {
      key_arn = data.aws_kms_key.this.arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]

  tags = merge(
    {
      Name = var.cluster_name
    },
    local.tag
  )
}
