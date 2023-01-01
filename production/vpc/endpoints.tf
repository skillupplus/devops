locals {
  vpc_endpoints = {
    "com.amazonaws.ap-northeast-2.ec2"     = "Interface"
    "com.amazonaws.ap-northeast-2.sts"     = "Interface"
    "com.amazonaws.ap-northeast-2.ecr.api" = "Interface"
    "com.amazonaws.ap-northeast-2.ecr.dkr" = "Interface"
    #"com.amazonaws.ap-northeast-2.elasticloadbalancing" = "Interface"
    #"com.amazonaws.ap-northeast-2.autoscaling" = "Interface"
  }

  endpoint_sg_name = "${var.name}-prod-endpoint-sg"
}

resource "aws_security_group" "endpoint" {
  name   = local.endpoint_sg_name
  vpc_id = local.vpc_id
}

resource "aws_security_group_rule" "endpoint_443" {
  security_group_id = aws_security_group.endpoint.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [for az in var.azs : var.private_subnets[az]]
}

resource "aws_vpc_endpoint" "this" {
  for_each = local.vpc_endpoints

  vpc_id              = local.vpc_id
  service_name        = each.key
  vpc_endpoint_type   = each.value
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]

  security_group_ids = [
    aws_security_group.endpoint.id
  ]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private.id
  ]
}
