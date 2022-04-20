
# -------------------------------------------------------------------------------------------------------------------------
# Lambda Function
# -------------------------------------------------------------------------------------------------------------------------

# Nơi lưu trữ files có type cụ thể, ở đây là "zip"
data "archive_file" "file_zip_app" {
  type = "zip"
  source_dir = "${path.module}/code/"
  output_path = "${path.module}/code/list.zip"
}

# Có thể lưu trữ trên S3 Bucket
# Sau khi up, kiểm tra: $ aws s3 ls $(terraform output -raw lambda_bucket_name)
/*
resource "aws_s3_object" "lambda_object" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key = "list.zip"
  source = data.archive_file.file_zip_app.output_path
  etag = filemd5(data.archive_file.file_zip_app.output_path)
}
*/

resource "aws_lambda_function" "function" {
  function_name = "Terraform-Lambda-Function"
  role = aws_iam_role.lambda_role.arn //allow logging to Group Log
  handler = "main" //Function entrypoint in your code (name of file code, example "main.go")
  runtime = "go1.x" //using code GOLANG

  # Lấy tệp zip code từ Local:
  filename = "${data.archive_file.file_zip_app.output_path}"

  # https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws
  # Lấy tệp zip code từ S3:
  # s3_bucket = aws_s3_bucket.lambda_bucket.id
  # s3_key = aws_s3_object.lambda_object

  # Sử dụng để kích hoạt update (".zip" is the local filename of the lambda function source archive):
  # source_code_hash = data.archive_file.file_zip_app.output_base64sha256

  depends_on = [ aws_iam_role_policy_attachment.attach ]
}

# Xác định một Log_Group để lưu trữ các thông báo nhật ký từ hàm Lambda trong 30 ngày
# Default, Lambda lưu trữ nhật ký trong một Group có tên: /aws/lambda/<Function Name>
# Có thể không cần tạo Resource này, Lambda Function khi create, nó sẽ tạo tự động Cloudwatch Log Group này bằng permission "logs:CreateLogGroup" trong IAM Policy!!!
resource "aws_cloudwatch_log_group" "lambda_log" {
  name = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = 1
}


# -------------------------------------------------------------------------------------------------------------------------
# API Gateway (HTTP API)
# -------------------------------------------------------------------------------------------------------------------------

# Thiết lập tên của API Gateway (HTTP API) và giao thức nó áp dụng:
resource "aws_apigatewayv2_api" "api_igw" {
  name = "terraform-api-igw-lambda"
  protocol_type = "HTTP"
}

# Integration với Lambda Function
resource "aws_apigatewayv2_integration" "api_igw" {
  api_id = aws_apigatewayv2_api.api_igw.id
  credentials_arn = aws_iam_role.api_igw.arn //permission for integration of API Gateway

  integration_uri = aws_lambda_function.function.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST" //HttpMethod must be "POST" for "AWS_PROXY" IntegrationType
}

# Ánh xạ request HTTP tới Target/Intergaration (Lambda Function)
resource "aws_apigatewayv2_route" "api_igw" {
  api_id = aws_apigatewayv2_api.api_igw.id
  route_key = "GET /get-list"
  target = "integrations/${aws_apigatewayv2_integration.api_igw.id}"
}

# Thiết lập stages của API
resource "aws_apigatewayv2_stage" "api_igw" {
  api_id = aws_apigatewayv2_api.api_igw.id
  name = "Test_1"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_igw.arn

    format = jsonencode({
      requestId               = "$context.requestId" //ID mà API Gateway chỉ định cho API request: logging lại giá trị trong header "x-amzn-RequestId". API Gateway trả về request ID này trong response header "x-amzn-RequestId" 
      extendedRequestId       = "$context.extendedRequestId" //ID mà API Gateway chỉ định cho API request: là một ID duy nhất mà API Gateway tạo ra. API Gateway trả về request ID này trong header phản hồi "x-amz-apigw-id".
      sourceIp                = "$context.identity.sourceIp" //Địa chỉ IP của kết nối TCP thực hiện yêu cầu đến điểm cuối API Gateway.
      requestTime             = "$context.requestTime" //logging time request
      protocol                = "$context.protocol" // The request protocol, for example, HTTP/1.1.
      httpMethod              = "$context.httpMethod" //GET/POST/...
      resourcePath            = "$context.resourcePath" //route_key
      routeKey                = "$context.routeKey" //The route key of the API request, for example /pets.
      status                  = "$context.status" //The method response status.
      responseLength          = "$context.responseLength" //The response payload length.
      integrationErrorMessage = "$context.integrationErrorMessage" //logging các error integration messages
    })
  }
}
resource "aws_cloudwatch_log_group" "api_igw" {
  name = "/aws/api_igw/${aws_apigatewayv2_api.api_igw.name}/${aws_apigatewayv2_stage.api_igw.name}"
  retention_in_days = 1
}

# Firewall for Lambda:
resource "aws_lambda_permission" "permission" {
  statement_id = "AllowExecutionFromAPIGateway" // cho phép thực thi từ API Gateway
  action = "lambda:InvokeFunction" // với thưc thi "invoke"
  function_name = aws_lambda_function.function.id
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api_igw.execution_arn}/*/*}"
}



# -------------------------------------------------------------------------------------------------------------------------
# API Gateway (REST API)
# -------------------------------------------------------------------------------------------------------------------------

# https://github.com/rampart81/terraform-aws-api-gateway/blob/develop/doc/how_to_setup_apigw.md
# API Gateway entity
resource "aws_api_gateway_rest_api" "api-gw" {
  name = "terraform-rest-api"
}

# Cũng giống như API Endpoint, API Gateway cần biết Resource & Method nào mà nó cần lắng nghe
resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part = "terraform-myresource"
}
resource "aws_api_gateway_method" "main" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = "GET" //hoặc ANY, chấp nhận bất kỳ method HTTP nào đi qua
  authorization = "NONE" //không áp dụng cơ chế ủy quyền trong API Gateway
}

# Sau đó, chúng ta cần cho APIGW biết phải làm gì với các request.
# Trong trường hợp này, forward request đến các hàm lambda (function). Phần này được gọi là "integration": tích hợp giữa API Gateway & Lambda function
resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  type = "AWS_PROXY" //for integrating the API method request with the Lambda function-invoking action with the client request passed through as-is. This integration is also referred to as the Lambda proxy integration.

  #integration_http_method = "GET" //method được áp dụng cho integration đến Backend
  # uri = "" //chứa endpoint đang ủy quyền
}

# Deployment
resource "aws_api_gateway_deployment" "api-gw" {
  depends_on = [ aws_api_gateway_integration.main ]
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name = "terraform"

  lifecycle {
    create_before_destroy = true
  }
}

# Allowing API Gateway to Access Lambda
resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  # Cấp quyền truy cập từ bất kỳ Method nào trên bất kỳ Resource nào trong API Gateway "REST API"
  source_arn = "${aws_api_gateway_deployment.api-gw}/*/*"
}



