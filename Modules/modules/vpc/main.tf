
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr-vpc
  enable_dns_support = var.dns-support
  enable_dns_hostnames = var.dns-hostname

  tags = {
    Name = "terraform-vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-igw-${var.env}"
    Project = "module"
    Environment = var.env
    ManagerBy = "terraform"
  }
}

# 2 Public Subnet to 2 AZ respectively -----------------------------------------------------------------------

resource "aws_subnet" "public-subnet" {
  for_each = var.public-subnet-number // 1 to 2 --> create 2 subnet with 2 AZ

  vpc_id = aws_vpc.vpc.id
  availability_zone = each.key // ap-southeast-1a to ap-southeast-1b
  cidr_block = cidrsubnet(var.cidr-vpc, 4, each.value) //tự động chia CIDR cho mỗi Subnet được tạo ra
  map_public_ip_on_launch = true
  
  tags = {
    Name = "terraform-public-subnet-${var.env}-${each.key}"
    Project = "module"
    Environment = var.env
    ManagerBy = "terraform"
    Role = "public"
    Subnet = "${each.key}-${each.value}"
  }
}

resource "aws_route_table" "public-subnets" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-routetable-for-public-subnet"
    Project = "module"
    Environment = var.env
    ManagerBy = "terraform"
  }
}

/*
data "aws_subnets" "public-subnets-id" {

  # Lọc các Subnet theo VPC mà nó thuộc vào
  filter {
    name = "vpc-id"
    values = [ "${aws_vpc.vpc.id}" ]
  }
  # Lọc để lấy được ID của các Public Subnet thông qua Tag:Role
  filter {
    name = "tag:Role"
    values = ["public"]
  }
}
*/

resource "aws_route_table_association" "public-subnets" {
  depends_on = [aws_subnet.public-subnet]
  # for_each = toset(data.aws_subnets.public-subnets-id.ids)
  for_each = aws_subnet.public-subnet

  subnet_id = each.value.id
  route_table_id = aws_route_table.public-subnets.id
}

# 2 Private Subnet to 2 AZ respectively ---------------------------------------------------------------------

resource "aws_subnet" "private-subnet" {
  for_each = var.private-subnet-number // 3 to 4 --> create 2 subnet with 2 AZ

  vpc_id = aws_vpc.vpc.id
  availability_zone = each.key // ap-southeast-1a to ap-southeast-1b
  cidr_block = cidrsubnet(var.cidr-vpc, 4, each.value)

  tags = {
    Name = "terraform-private-subnet-${var.env}-${each.key}"
    Project = "module"
    Environment = var.env
    ManagerBy = "terraform"
    Role = "private"
    Subnet = "${each.key}-${each.value}"
  }
}

resource "aws_route_table" "nat-instance" {
  count = var.enable-nat-gateway ? 0 : 1 //false

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = var.interface-network //ID network interface of NAT Instance
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name = "terraform-routetable-for-private-subnet-nat-instance-${var.env}"
    Project = "module"
    Environment = var.env
    ManagerBy = "terraform"
  }
}

/*
data "aws_subnets" "private-subnets-id" {

  # Lọc các Subnet theo VPC mà nó thuộc vào
  filter {
    name = "vpc-id"
    values = [ "${aws_vpc.vpc.id}" ]
  }
  # Lọc để lấy được ID của các Private Subnet thông qua Tag:Role
  filter {
    name = "tag:Role"
    values = ["private"]
  }
}
*/

resource "aws_route_table_association" "nat-instance" {
  # for_each = var.enable-nat-gateway ? {} : toset(data.aws_subnets.private-subnets-id.ids)
  for_each = var.enable-nat-gateway ? {} : aws_subnet.private-subnet //false

  # subnet_id = each.value //if config (have data resource)
  subnet_id = each.value.id //if config (no data source)
  route_table_id = aws_route_table.nat-instance[0].id
}

# Subnet Group for Database -----------------------------------------------------------

resource "aws_db_subnet_group" "subnet-group" {
  subnet_ids = values(aws_subnet.private-subnet)[*].id
  name = "terraform-private-subnet-group-${var.env}"
}


# NAT Gateway --------------------------------------------------------------------------

resource "aws_eip" "nat-gateway" {
  count = var.enable-nat-gateway ? 1 : 0 //true
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  # for_each = var.enable-nat-gateway ? toset(data.aws_subnets.private-subnets-id.ids) : {} //true
  for_each = var.enable-nat-gateway ? aws_subnet.private-subnet : {} //true

  subnet_id = each.value.id
  allocation_id = aws_eip.nat-gateway[0].id

  tags = {
    Name = "terraform-nat-gateway-for-private-subnets"
  }
}

resource "aws_route_table" "nat-gateway" {
  count = var.enable-nat-gateway ? 1 : 0 //true

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_nat_gateway.nat-gateway[0].id
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name = "terraform-routetable-for-private-subnet-nat-gateway"
    Project = "module"
    Environment = var.env
    ManagerBy = "terraform"
  }
}

resource "aws_route_table_association" "nat-gateway" {
  for_each = var.enable-nat-gateway ? aws_subnet.private-subnet : {} //true

  subnet_id = each.value.id
  route_table_id = aws_route_table.nat-gateway[0].id
}

