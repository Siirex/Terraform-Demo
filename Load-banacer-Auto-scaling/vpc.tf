
resource "aws_vpc" "terraform-vpc" {
  cidr_block = var.terraform-vpc-test
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc-eboi"
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  
  tags = {
    Name = "terraform-igw-eboi"
  }
}

# ------------------------------------------------------- Public Subnet inside AZ (1a)

resource "aws_subnet" "public-subnet-1a" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-public-subnet-1a
  availability_zone = var.terraform-az-1a

  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet-1a"
  }
}

resource "aws_route_table" "public-rt-1a" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-igw.id
  }

  tags = {
    Name = "terraform-rt-public-subnet-1a"
  }
}

resource "aws_route_table_association" "public-1a" {
  subnet_id = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.public-rt-1a.id
}

# ------------------------------------------------------- Public Subnet inside AZ (1b)

resource "aws_subnet" "public-subnet-1b" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-public-subnet-1b
  availability_zone = var.terraform-az-1a

  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet-1b"
  }
}

resource "aws_route_table" "public-rt-1b" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-igw.id
  }

  tags = {
    Name = "terraform-rt-public-subnet-1b"
  }
}

resource "aws_route_table_association" "public-1b" {
  subnet_id = aws_subnet.public-subnet-1b.id
  route_table_id = aws_route_table.public-rt-1b.id
}

# ------------------------------------------------------- Private Subnet inside AZ (1a)

resource "aws_subnet" "private-subnet-1a" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-private-subnet-1a
  availability_zone = var.terraform-az-1a

  tags = {
    Name = "terraform-private-subnet-1a"
  }
}

# ------------------------------------------------------- Private Subnet inside AZ (1b)

resource "aws_subnet" "private-subnet-1b" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = var.terraform-private-subnet-1b
  availability_zone = var.terraform-az-1b

  tags = {
    Name = "terraform-private-subnet-1b"
  }
}


# ------------------------------------------------------- Subnet Group for AZ (1a, 1b)

resource "aws_db_subnet_group" "terraform-subnet-group" {
  subnet_ids = [aws_subnet.private-subnet-1a.id, aws_subnet.private-subnet-1b.id]

  tags = {
    Name = "terraform-subnet-group"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "terraform-rt-private-subnet"
  }
}
