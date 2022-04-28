
output "asg_id" {
  value = aws_autoscaling_group.container_instance.id
}

output "sg_container_instance_id" {
  value = aws_security_group.container_instance.id
}
