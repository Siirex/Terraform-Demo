
resource "aws_cloudwatch_log_group" "log_group" {
  name = var.logs_group_name
  retention_in_days = 1
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name = var.logs_stream_name
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
