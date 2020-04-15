resource "aws_network_acl" "cluster-acl" {
  vpc_id     = aws_vpc.cluster-vpc.id
  subnet_ids = [aws_subnet.private-subnet.id]
  # allow ingress port 22
  /*
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "183.98.30.10/32"
    from_port  = 22
    to_port    = 22
  }
  */
  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8443
    to_port    = 8443
  }

  ingress {
    protocol   = -1
    rule_no    = 200
    action     = "allow"
    cidr_block = "183.98.30.10/32"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol = -1
    rule_no  = 201
    action   = "allow"
    //cidr_block = "183.98.30.10/32"
    cidr_block = var.allow_ip
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 501
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }
  ingress {
    protocol   = "udp"
    rule_no    = 502
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 503
    action     = "allow"
    cidr_block = "15.165.86.0/24"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = -1
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  /*
  egress {
    protocol   = "tcp"
    rule_no    = 800
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  */
  egress {
    protocol   = "udp"
    rule_no    = 504
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }
  /*
  subnet_ids = [
    "${aws_subnet.public_1a.id}",
    "${aws_subnet.private_1a.id}",
  ]
  */
  tags = {
    Name = "acl Example"
  }
}

resource "aws_eip" "cluster-eip" {
  count = var.use-eip == "true" ? 1 : 0
  vpc   = true
}
resource "aws_eip_association" "cluster-eip-association" {
  count         = var.use-eip == "true" ? 1 : 0
  instance_id   = aws_instance.mgmt[0].id
  allocation_id = aws_eip.cluster-eip[0].id
}
resource "aws_internet_gateway" "cluster-gw" {

  vpc_id = aws_vpc.cluster-vpc.id
  tags = {
    Name = "internet-gateway"
  }
}

# 기본 라우팅이 없어서 2개 생성
resource "aws_route_table" "route-pri" {
  vpc_id = aws_vpc.cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster-gw.id
  }
  tags = {
    Nmae = "private Route"
  }
}

resource "aws_route_table_association" "cluster-vpc-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.route-pri.id

}

resource "aws_security_group" "cluster-sg" {
  vpc_id      = aws_vpc.cluster-vpc.id
  name        = "NDAP Security Group"
  description = "Allow http port from all Test"
  //SSH
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.cluster-vpc.id
  availability_zone       = var.aws_avail_zone
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = false
  tags = {
    Name = "private subnet"
  }
}

resource "aws_vpc" "cluster-vpc" {
  cidr_block = var.vpc_cidr
  //enable_dns_hostnames = true            // 이게 뭘까?
  //enable_dns_support   = true            // 이게 뭘까?
  enable_dns_hostnames = false
  instance_tenancy     = "default"

  tags = {
    Name = "Private VPC for Cluster"
  }
}

