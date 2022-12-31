data "aws_availability_zones" "available" {}

locals {
  tag = {
    ProjectName = var.name
    ManagedBy   = "terraform"
  }
  cluster_name = "${var.name}-apne2-alpha"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-production"
  }
}

locals {
  vpc_id = aws_vpc.this.id
}

################################################################################
# IGW
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.name}-production"
  }
}

locals {
  igw_id = aws_internet_gateway.this.id
}

################################################################################
# Public Routes
################################################################################

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.name}-production-public-rt"
  }
}

locals {
  public_rt_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = local.public_rt_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.igw_id
}


################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id            = local.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                                          = "${var.name}-production-public-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
}

################################################################################
# Public route table association
################################################################################

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = local.public_rt_id
}

################################################################################
# Private Routes
################################################################################

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.name}-production-private-rt"
  }
}

locals {
  private_rt_id = aws_route_table.private.id
}

################################################################################
# private Subnets
################################################################################

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = local.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                                          = "${var.name}-production-private-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

################################################################################
# Private route table association
################################################################################

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = local.private_rt_id
}
