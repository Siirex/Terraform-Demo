
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr-vpc

  enable_dns_support   = true 
  enable_dns_hostnames = true 
  
  tags = {
    Name = "terraform-vpc-${var.owner}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-igw-${var.owner}"
  }
}

# -------------------------------------- 2 Private subnet with 2 AZ

resource "aws_subnet" "public-subnet" {
  count = length(var.cidr-public-subnet)

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr-public-subnet[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet-${count.index}-${var.owner}"
  }
}

resource "aws_route_table" "public-subnet-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-public-subnet-rt-${var.owner}"
  }
}

resource "aws_route_table_association" "public-subnet-rt-ass" {
  count = length(var.cidr-public-subnet)
  
  subnet_id = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-subnet-rt.id
}

# -------------------------------------- 2 Private subnet with 2 AZ

resource "aws_subnet" "private-subnet" {
  count = length(var.cidr-private-subnet)

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr-private-subnet[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "terraform-private-subnet-${count.index}-${var.owner}"
  }
}

resource "aws_route_table" "private-subnet-rt" {
  vpc_id = aws_vpc.vpc.id

  # Allow communicate with Internet by NAT_Instance
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.nat-instance-interface.id 
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name = "terraform-private-subnet-rt-${var.owner}"
  }
}

resource "aws_route_table_association" "private-subnet-rt-ass" {
  count = length(var.cidr-private-subnet)

  subnet_id = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-subnet-rt.id
}

# -------------------------------------- Subnet Group for Database

resource "aws_db_subnet_group" "subnet-group" {
  # subnet_ids = [ aws_subnet.private-subnet.id ] //error
  subnet_ids = [ "${aws_subnet.private-subnet[0].id}", "${aws_subnet.private-subnet[1].id}" ]
  name = "terraform-private-subnet-group-${var.owner}"
}

