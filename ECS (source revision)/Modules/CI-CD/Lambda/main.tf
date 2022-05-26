
# --------------------------------------------
# Lambda function được trigger từ CodeCommit
# --------------------------------------------

# Function excute CloudWatch Log: logging source revision on CodeCommit (when receiving a notification from SNS topic)
resource "aws_lambda_function" "cloudwatchlogs" {
  function_name = var.function_log

  role = var.role_log
  handler = var.handler_log
  runtime = var.runtime_log

  s3_bucket = var.bucket_id
  s3_key = var.bucket_function_log_key

  # filename = var.file_function_log
}

# Function excute CodeBuild: automation activated Build process (when receiving a notification from SNS topic)
resource "aws_lambda_function" "codebuild" {
  count = var.use_pipline ? 0 : 1
  function_name = var.function_build

  role = var.role_build
  handler = var.handler_build
  runtime = var.runtime_build

  s3_bucket = var.bucket_id
  s3_key = var.bucket_function_build_key

  # filename = var.file_function_build
}

# Lambda function 'build' được trigger trực tiếp từ CodeCommit events - để thực thi Codebuid
# Sau khi được Codecommit trigger (theo events đã được thiết lập), Lambda function sẽ chạy để báo hiệu CodeBuild bắt đầu build
resource "aws_lambda_permission" "allow_codecommit" {
  count = var.use_pipline ? 0 : 1

  statement_id = var.statement_allow
  action = var.action_allow
  function_name = aws_lambda_function.codebuild[0].function_name
  principal = var.principal_allow
  source_arn = var.codecommit_repo_arn
}


