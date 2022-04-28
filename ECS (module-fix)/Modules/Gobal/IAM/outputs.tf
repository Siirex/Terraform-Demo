
output "iam_profile" {
  value = aws_iam_instance_profile.profile.name
}

output "ecs_task_exec_role_arn" {
  value = aws_iam_role.ecs_task_exec_role.arn
}

output "ecs_ecs_role_arn" {
  value = aws_iam_role.ecs_service_role.arn
}
