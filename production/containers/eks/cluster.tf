################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "cluster" {
  name               = "${var.name}-eks-role"
  description        = "EKS Cluster iam role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_cluster.json

  tags = merge({
    Name = "${var.name}-eks-role"
    },
    local.tag
  )
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

locals {
  cluster_role_arn = aws_iam_role.cluster.arn
}

################################################################################
# Security Groups
################################################################################

locals {
  cluster_security_group_id = aws_security_group.cluster.id
}
resource "aws_security_group" "cluster" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  # eks-cluster-sg-skillup-apne2-alpha-1166471036
  name = "eks-cluster-sg-${var.cluster_name}-cluster"

  tags = merge(
    {
      Name                                        = "${var.cluster_name}-cluster"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    local.tag
  )
}

resource "aws_security_group_rule" "ingress_all" {
  security_group_id = local.cluster_security_group_id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = local.cluster_security_group_id
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
  role_arn = local.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [local.cluster_security_group_id]
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

locals {
  cluster_name = aws_eks_cluster.this.name
}

################################################################################
# Addon
################################################################################

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = local.cluster_name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni.version


  resolve_conflicts = "OVERWRITE"
  configuration_values = jsonencode({
    env = {
      # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })
}
