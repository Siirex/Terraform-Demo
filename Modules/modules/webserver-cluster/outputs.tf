
output "dns_alb" {
  value = aws_alb.alb.dns_name
}

output "sg_alb_id" {
  value = aws_security_group.sg-alb.id
}

output "sg_asg_id" {
  value = aws_security_group.sg-asg.id
}



