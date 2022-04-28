
output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "targetgroup_arn" {
  value = aws_lb_target_group.alb.arn
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}
