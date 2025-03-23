
resource "aws_vpc" "aff2_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "aff2_VPC"
  }
}


resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.aff2_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE1
  tags = {
    Name = "Public_Subnet_1"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.aff2_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE2
  tags = {
    Name = "Public_Subnet_2"
  }
}


resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.aff2_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE1
  tags = {
    Name = "private_subnet_1"
  }
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.aff2_vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE2
  tags = {
    Name = "private_subnet_2"
  }
}

# Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc" # Reemplaza 'vpc = true' con 'domain = "vpc"'
  tags = {
    Name = "NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "NAT-GW"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.aff2_vpc.id
  tags = {
    Name = "IGW"
  }
}
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.aff2_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private_RT"
  }
}

resource "aws_route_table_association" "private_subnet_1a" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_RT.id
}

resource "aws_route_table_association" "private_subnet_2b" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_RT.id
}

resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.aff2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public_RT"
  }
}


resource "aws_route_table_association" "public_subnet_1a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_RT.id
}


resource "aws_route_table_association" "public_subnet_2b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_RT.id
}

