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

resource "aws_instance" "nat_instance" {
  ami               = data.aws_ami.nat_instance.id
  instance_type     = "t3.nano"
  availability_zone = local.nat_instance_az
  subnet_id         = aws_subnet.public[local.nat_instance_az].id

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
  nat_instance_id = aws_instance.nat_instance.id
}
