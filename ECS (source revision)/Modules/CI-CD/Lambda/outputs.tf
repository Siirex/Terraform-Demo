
output "fucntion_logs_name" {
  value = aws_lambda_function.cloudwatchlogs.function_name
}

output "fucntion_build_name" {
  value = aws_lambda_function.codebuild.*.function_name
}

output "funtion_logs_arn" {
  value = aws_lambda_function.cloudwatchlogs.arn
}

output "funtion_build_arn" {
  value = aws_lambda_function.codebuild.*.arn
}
