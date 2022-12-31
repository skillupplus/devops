################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "node_group" {
  name               = "${var.name}-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_node_group.json

  tags = merge({
    Name = "${var.name}-node-group-role"
    },
    local.tag
  )
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

locals {
  node_group_role_arn = aws_iam_role.node_group.arn
}

################################################################################
# Node Groups
################################################################################

# resource "aws_eks_node_group" "default" {
#   cluster_name    = local.cluster_name
#   node_group_name = "${var.cluster_name}-default"
#   node_role_arn   = local.node_group_role_arn
#   subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids

#   capacity_type  = "SPOT"
#   instance_types = ["t3a.medium"]
#   disk_size      = 20

#   version = var.cluster_version

#   scaling_config {
#     desired_size = 1
#     min_size     = 1
#     max_size     = 2
#   }


#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
#   ]

#   tags = merge(
#     {
#       Name = "${var.cluster_name}-default"
#     },
#     local.tag
#   )
# }
