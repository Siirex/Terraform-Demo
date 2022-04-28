
output "logs_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}

output "logs_stream_name" {
  value = aws_cloudwatch_log_stream.log_stream.name
}
