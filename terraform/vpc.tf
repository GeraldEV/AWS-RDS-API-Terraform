# AWS Networking

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name} VPC"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_public_a
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project_name} Public Subnet A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_public_b
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project_name} Public Subnet B"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_private_a
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project_name} Private Subnet A"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_private_b
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project_name} Private Subnet B"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name} IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name} Public Route Table"
  }
}

resource "aws_route_table_association" "subnet_public_a_route" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_public_b_route" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpn_gateway" "internal" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name} Internal VPN GW"
  }
}

resource "aws_route" "internal_default_route" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_vpn_gateway.internal.id
}

resource "aws_route_table_association" "subnet_private_a_route" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_route_table_association" "subnet_private_b_route" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_security_group" "main" {
  name        = "${var.project_name}SG"
  description = "Security group for database API services"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name} Security Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ipv4_service_port" {
  security_group_id = aws_security_group.main.id
  description       = "Allow TCP traffic to service port from your network"

  cidr_ipv4   = var.my_network
  from_port   = var.ingress_specs.port
  to_port     = var.ingress_specs.port
  ip_protocol = var.ingress_specs.protocol
}

resource "aws_vpc_security_group_ingress_rule" "internal" {
  security_group_id = aws_security_group.main.id
  description       = "Allow all internal traffic"

  referenced_security_group_id = aws_security_group.main.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.main.id
  description       = "Allow all outbound IPv4 traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

