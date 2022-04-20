
# -------------------------------------------------------------------------------------------------------------------------
# Lambda Function - for "list" data
# -------------------------------------------------------------------------------------------------------------------------

# Nơi lưu trữ files có type cụ thể, ở đây là "zip"
data "archive_file" "file_zip_list" {
  type = "zip"
  source_dir = "${path.module}/code-list/"
  output_path = "${path.module}/code-list/list.zip"
}

# Có thể lưu trữ trên S3 Bucket
# Sau khi up, kiểm tra: $ aws s3 ls $(terraform output -raw lambda_bucket_name)
/*
resource "aws_s3_object" "lambda_object" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key = "list.zip"
  source = data.archive_file.file_zip_list.output_path
  etag = filemd5(data.archive_file.file_zip_list.output_path)
}
*/

resource "aws_lambda_function" "list" {
  function_name = "Terraform-function-list-data"
  role = aws_iam_role.lambda_role.arn //allow logging to Group Log
  handler = "main" //Function entrypoint in your code (name of file code, example "main.go")
  runtime = "go1.x" //using code GOLANG

  # Lấy tệp zip code từ Local:
  filename = "${data.archive_file.file_zip_list.output_path}"

  # https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws
  # Lấy tệp zip code từ S3:
  # s3_bucket = aws_s3_bucket.lambda_bucket.id
  # s3_key = aws_s3_object.lambda_object

  # Sử dụng để kích hoạt update (".zip" is the local filename of the lambda function source archive):
  # source_code_hash = data.archive_file.file_zip_list.output_base64sha256

  depends_on = [ aws_iam_role_policy_attachment.attach ]
}

# Xác định một Log_Group để lưu trữ các thông báo nhật ký từ hàm Lambda trong 30 ngày
# Default, Lambda lưu trữ nhật ký trong một Group có tên: /aws/lambda/<Function Name>
# Có thể không cần tạo Resource này, Lambda Function khi create, nó sẽ tạo tự động Cloudwatch Log Group này bằng permission "logs:CreateLogGroup" trong IAM Policy!!!
resource "aws_cloudwatch_log_group" "list_function_log" {
  name = "/aws/lambda/${aws_lambda_function.list.function_name}"
  retention_in_days = 1
}


