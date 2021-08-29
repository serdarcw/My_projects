resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_public_subnet_A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_A_cidr
  availability_zone = "${local.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "main_public_subnet_A"
  }
}

resource "aws_subnet" "main_public_subnet_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_B_cidr
  availability_zone = "${local.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "main_public_subnet_B"
  }
}

resource "aws_subnet" "main_private_subnet_A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_A_cidr
  availability_zone = "${local.region}a"
  tags = {
    Name = "main_private_subnet_A"
  }
}

resource "aws_subnet" "main_private_subnet_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_B_cidr
  availability_zone = "${local.region}b"

  tags = {
    Name = "main_private_subnet_B"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "main_public_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_public_RT"
  }
}

resource "aws_route_table" "main_private_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_gw.id
  }

  tags = {
    Name = "main_private_RT"
  }
}

resource "aws_route_table_association" "public_A_assos" {
  subnet_id      = aws_subnet.main_public_subnet_A.id
  route_table_id = aws_route_table.main_public_RT.id
}

resource "aws_route_table_association" "public_B_assos" {
  subnet_id      = aws_subnet.main_public_subnet_B.id
  route_table_id = aws_route_table.main_public_RT.id
}

resource "aws_route_table_association" "private_A_assos" {
  subnet_id      = aws_subnet.main_private_subnet_A.id
  route_table_id = aws_route_table.main_private_RT.id
}

resource "aws_route_table_association" "private_B_assos" {
  subnet_id      = aws_subnet.main_private_subnet_B.id
  route_table_id = aws_route_table.main_private_RT.id
}

resource "aws_eip" "main_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "Nat_gw" {
  allocation_id = aws_eip.main_eip.id
  subnet_id     = aws_subnet.main_public_subnet_A.id
  depends_on    = [aws_internet_gateway.main_igw]

  tags = {
    Name = "NAT Gateway"
  }
}