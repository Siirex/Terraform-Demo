
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    "Name" = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "terraform-igw"
  }
}

# 2 Public Subnets with 2AZ
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.vpc.id
  availability_zone = element(var.azs, count.index)
  cidr_block = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# 2 Private Subnets with 2AZ
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.vpc.id
  availability_zone = element(var.azs, count.index)
  cidr_block = element(var.private_subnets, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

/*

# -------------------------------------------------

resource "aws_subnet" "public__a" {
  availability_zone = "ap-southeast-1a"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public__b" {
  availability_zone = "ap-southeast-1b"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public__a.id
}

resource "aws_route_table_association" "public_b" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public__b.id
}

# --------------------------------------------------

resource "aws_subnet" "private__a" {
  availability_zone = "ap-southeast-1a"
  cidr_block = "10.1.3.0/24"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "private__b" {
  availability_zone = "ap-southeast-1b"
  cidr_block = "10.1.4.0/24"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private__a.id
}

resource "aws_route_table_association" "private_b" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private__b.id
}

*/
