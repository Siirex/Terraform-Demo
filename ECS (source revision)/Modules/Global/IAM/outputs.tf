
output "ecs_task_exec_role_arn" {
  value = aws_iam_role.ecs_task_exec_role.arn
}

output "ecs_ecs_role_arn" {
  value = aws_iam_role.ecs_service_role.arn
}

# --------------------------------------------

output "role_function_log" {
  value = aws_iam_role.function_logs.arn
}

output "role_function_build" {
  value = aws_iam_role.function_build.arn
}

output "role_codebuild" {
  value = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

# --------------------------------------------

output "role_codepipline" {
  value = aws_iam_role.pipeline.arn
}

output "role_codedeploy" {
  value = aws_iam_role.codedeploy.arn
}

# -------------------------------------------

output "role_ecs_eventbridge" {
  value = aws_iam_role.ecs_events.arn
}

/*
output "role_sns_eventbridge" {
  value = aws_iam_role.sns_events.arn
}
*/

