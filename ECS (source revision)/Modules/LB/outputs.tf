
output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}

# -------------------------------------

output "targetgroup_name" {
  value = aws_lb_target_group.alb.name
}

output "targetgroup_arn" {
  value = aws_lb_target_group.alb.arn
}

output "listener_arn" {
  value = aws_lb_listener.alb.arn
}

# -------------------------------------

output "green_target_name" {
  value = aws_lb_target_group.green_lb_target.*.name
}

output "green_target_arn" {
  value = aws_lb_target_group.green_lb_target.*.arn
}

output "green_listener_arn" {
  value = aws_lb_listener.green_listener.*.arn
}

