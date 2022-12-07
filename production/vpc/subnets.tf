# Public Subnets

resource "aws_subnet" "ap_northeast_2a_public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, var.ap_northeast_2a_public_network)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.name}-a-public"
  }
}

resource "aws_subnet" "ap_northeast_2c_public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, var.ap_northeast_2c_public_network)
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.name}-c-public"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-rt"
  }
}

resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "ap_northeast_2a_public" {
  subnet_id      = aws_subnet.ap_northeast_2a_public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "ap_northeast_2c_public" {
  subnet_id      = aws_subnet.ap_northeast_2c_public.id
  route_table_id = aws_route_table.public.id
}

# Private Subnets

resource "aws_subnet" "ap_northeast_2a_private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, var.ap_northeast_2a_private_network)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.name}-a-private"
  }
}

resource "aws_subnet" "ap_northeast_2c_private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, var.ap_northeast_2c_private_network)
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.name}-c-private"
  }
}
