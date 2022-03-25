
resource "aws_vpc" "terraform-vpc" {
  cidr_block = var.terraform-vpc-test
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc-${var.owner}"
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  
  tags = {
    Name = "terraform-igw-${var.owner}"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-public-subnet
  availability_zone = var.terraform-az-1a

  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet-${var.owner}"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-igw.id
  }

  tags = {
    Name = "terraform-rt-public-subnet-${var.owner}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}


resource "aws_subnet" "private-subnet-1a" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-private-subnet-1a
  availability_zone = var.terraform-az-1a

  tags = {
    Name = "terraform-private-subnet-1a-${var.owner}"
  }
}

resource "aws_subnet" "private-subnet-1b" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-private-subnet-1b
  availability_zone = var.terraform-az-1b

  tags = {
    Name = "terraform-private-subnet-1b-${var.owner}"
  }
}

resource "aws_db_subnet_group" "terraform-subnet-group" {
  subnet_ids = [aws_subnet.private-subnet-1a.id, aws_subnet.private-subnet-1b.id]

  tags = {
    Name = "terraform-subnet-group-${var.owner}"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.terraform-vpc.id
  
  # no route? --> use 'default route' with route: destination "cidr_vpc", target "local"

  tags = {
    Name = "terraform-rt-private-subnet-${var.owner}"
  }
}

resource "aws_route_table_association" "private-rt" {
  subnet_id = aws_db_subnet_group.terraform-subnet-group.id //association 'Private Subnet Group' to ...
  route_table_id = aws_route_table.private-rt.id
}