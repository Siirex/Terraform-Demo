
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    "Name" = "terraform-vpc-${var.app}-${var.env}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "terraform-igw-${var.app}-${var.env}"
  }
}

# 2 Public Subnets with 2AZ
resource "aws_subnet" "public" {
  count = length(var.public_cidr)

  vpc_id = aws_vpc.vpc.id
  availability_zone = element(var.azs, count.index)
  cidr_block = element(var.public_cidr, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet-${count.index + 1}-${var.app}-${var.env}"
  }
}

# 2 Private Subnets with 2AZ
resource "aws_subnet" "private" {
  count = length(var.private_cidr)

  vpc_id = aws_vpc.vpc.id
  availability_zone = element(var.azs, count.index)
  cidr_block = element(var.private_cidr, count.index)

  tags = {
    Name = "terraform-private-subnet-${count.index + 1}-${var.app}-${var.env}"
  }
}

# EIP
resource "aws_eip" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0 //true
  vpc = true
}

# 1 NAT Gateway on 1 PublicSubnet/AZ
resource "aws_nat_gateway" "nat_gateway_one" {
  count = var.create_1_nat_gateway_on_1_AZ ? 1 : 0 //true

  subnet_id = aws_subnet.public[0].id
  allocation_id = aws_eip.nat_gateway[0].id

  tags = {
    Name = "terraform-nat-gateway-${var.app}-${var.env}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-public-rt-${var.app}-${var.env}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-private-rt-${var.app}-${var.env}"
  }
}

resource "aws_route" "nat_gateway_one" {
  count = var.create_1_nat_gateway_on_1_AZ ? 1 : 0 //true

  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway_one[0].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}




