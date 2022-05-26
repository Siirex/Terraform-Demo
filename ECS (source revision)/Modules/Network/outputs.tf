
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_id" {
  value = [
    for subnet in aws_subnet.public : subnet.id
  ]
}

output "private_subnet_id" {
  value = [
    for subnet in aws_subnet.private : subnet.id
  ]
}

output "az" {
  value = [ for az in aws_subnet.public : az.availability_zone ]
}
