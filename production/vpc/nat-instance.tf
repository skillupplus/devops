data "aws_ami" "nat_instance" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }
}

locals {
  nat_instance_az = "ap-northeast-2a"
}

################################################################################
# VPC Security
################################################################################

################################################################################
# NAT Instance
################################################################################

data "aws_iam_role" "ec2-ssm" {
  name = "ec2-ssm"
}

resource "aws_iam_instance_profile" "nat_instance" {
  name = "${var.name}-production-nat-instance-profile"
  role = data.aws_iam_role.ec2-ssm.id
}

resource "aws_instance" "nat_instance" {
  ami               = data.aws_ami.nat_instance.id
  instance_type     = "t3.nano"
  availability_zone = local.nat_instance_az
  subnet_id         = aws_subnet.public[local.nat_instance_az].id

  iam_instance_profile = aws_iam_instance_profile.nat_instance.id

  vpc_security_group_ids = [
    local.default_sg_id
  ]

  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "${var.name}-production-nat-instance"
  }
}

locals {
  nat_instance_id     = aws_instance.nat_instance.id
  nat_instance_eni_id = aws_instance.nat_instance.primary_network_interface_id
}
