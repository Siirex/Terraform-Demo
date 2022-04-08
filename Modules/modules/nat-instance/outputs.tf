
output "sg-nat-instance-id" {
  value = aws_security_group.sg-nat-instance.id
}

output "interface-network" {
  value = aws_network_interface.nat-instance.id
}


