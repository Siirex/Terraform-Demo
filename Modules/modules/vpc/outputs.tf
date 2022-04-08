
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

/*
output "public_subnets" {
  value = {
    for subnet in aws_subnet.public-subnet : subnet.id => subnet.cidr_block
  }
}

output "private_subnets" {
  value = {
    for subnet in aws_subnet.private-subnet : subnet.id => subnet.cidr_block
  }
}

output "private_subnets_ids" {
  value = [ "${aws_subnet.private-subnet.*.id}" ] //???
}

output "public_subnets_ids" {
  value = [ "${aws_subnet.public-subnet.*.id}" ] //???
}
*/

output "public_subnets" {
  value = [
    for subnet in aws_subnet.public-subnet : subnet.id
  ]
}
output "private_subnets" {
  value = [
    for subnet in aws_subnet.private-subnet : subnet.id
  ]
}

output "az" {
  value = [ for az in aws_subnet.public-subnet : az.availability_zone ] //???
}

output "db_subnet_group" {
  value = aws_db_subnet_group.subnet-group.id
}
