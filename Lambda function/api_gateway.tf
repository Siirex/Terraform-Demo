

# -------------------------------------------------------------------------------------------------------------------------
# API Gateway (HTTP API)
# -------------------------------------------------------------------------------------------------------------------------

# Thiết lập API Gateway (HTTP API) - point cho các call request vào các Integration được áp dụng (ở đây là Lambda integration)
resource "aws_apigatewayv2_api" "api_igw" {
  name = "terraform-api-igw-lambda"
  protocol_type = "HTTP"
}

# -------------------------------------------------------------------------------------------------------------------------
# Lambda Integration for "list" & "create" function
# Integration với các Lambda Function (nhiều function được call, sẽ có nhiều Integration tương ứng với các function đó)
# -------------------------------------------------------------------------------------------------------------------------

# list
resource "aws_apigatewayv2_integration" "list" {
  api_id = aws_apigatewayv2_api.api_igw.id
  credentials_arn = aws_iam_role.api_igw.arn //permission for integration of API Gateway

  integration_uri = aws_lambda_function.list.invoke_arn //with Function "list"
  integration_type = "AWS_PROXY" //dùng cho Integration Lambda
  integration_method = "POST" //HttpMethod must be "POST" for "AWS_PROXY" IntegrationType
}

# create
resource "aws_apigatewayv2_integration" "create" {
  api_id = aws_apigatewayv2_api.api_igw.id
  credentials_arn = aws_iam_role.api_igw.arn

  integration_uri = aws_lambda_function.create.invoke_arn //with Function "create"
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

# -------------------------------------------------------------------------------------------------------------------------
# API Route for "list" & "create" function
# Ánh xạ request HTTP tới các Target/Intergaration (nhiều function được call, sẽ có nhiều Route tương ứng với các Integration của các function đó)
# -------------------------------------------------------------------------------------------------------------------------

# list
resource "aws_apigatewayv2_route" "list" {
  api_id = aws_apigatewayv2_api.api_igw.id
  route_key = "GET /get-list" // Client sẽ call Lambda function "list" thông qua method "GET" đến API Gateway với URI: "<id>.execute-api.ap-southeast-1.amazonaws.com/<stage_name>/get-list"
  target = "integrations/${aws_apigatewayv2_integration.list.id}" //integration with "list" function
}

# create
resource "aws_apigatewayv2_route" "create" {
  api_id = aws_apigatewayv2_api.api_igw.id
  route_key = "POST /post-create" // Client sẽ call Lambda function "create" thông qua method "POST" đến API Gateway với URI: "<id>.execute-api.ap-southeast-1.amazonaws.com/<stage_name>/post-create"
  target = "integrations/${aws_apigatewayv2_integration.create.id}" //integration with "create" function
}

# -------------------------------------------------------------------------------------------------------------------------
# Stage for API
# Thiết lập stages của API (Stage sẽ là duy nhất cho mỗi API Gateway, nhiều function (list & create) được call cũng sẽ chỉ thực thi dựa trên Stage này)
# -------------------------------------------------------------------------------------------------------------------------

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
  name = "/aws/api_igw/${aws_apigatewayv2_api.api_igw.name}"
  retention_in_days = 1
}

# -------------------------------------------------------------------------------------------------------------------------
# Permission for API Gateway: Allow access Lambda Function
# -------------------------------------------------------------------------------------------------------------------------

# Firewall for Lambda:
resource "aws_lambda_permission" "permission" {
  statement_id = "AllowExecutionFromAPIGateway" // cho phép thực thi từ API Gateway
  action = "lambda:InvokeFunction" // với thưc thi "invoke"
  function_name = aws_lambda_function.list.id
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api_igw.execution_arn}/*/*}"
}


