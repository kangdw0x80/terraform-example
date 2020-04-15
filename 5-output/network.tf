resource "aws_network_acl" "test_acl" {
  vpc_id     = aws_vpc.test_pri.id
  subnet_ids = [aws_subnet.private.id]

  ingress {
    protocol   = -1 // all
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl Example"
  }
}


resource "aws_eip" "test_eip" {
  instance = aws_instance.mgmt.id
  vpc      = true
}
resource "aws_internet_gateway" "test_gw" {

  vpc_id = aws_vpc.test_pri.id
  tags = {
    Name = "internet-gateway"
  }
}


resource "aws_route_table" "route_pri" {
  vpc_id = aws_vpc.test_pri.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_gw.id
  }
  tags = {
    Nmae = "private Route"
  }
}


resource "aws_route_table_association" "test_vpc_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route_pri.id

}

resource "aws_security_group" "dev_ssh" {
  vpc_id      = aws_vpc.test_pri.id
  name        = "NDAP SSH"
  description = "Allow http port from all Test"
  //SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.test_pri.id
  availability_zone       = var.avail_zone
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "private subnet"
  }
}

resource "aws_vpc" "test_pri" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = false
  instance_tenancy     = "default"

  tags = {
    Name = "Private VPC for NDAP"
  }
}

