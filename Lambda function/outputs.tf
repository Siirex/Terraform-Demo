
output "invoke_url" {
  value = aws_apigatewayv2_stage.api_igw.invoke_url
}

output "function_name" {
  value = aws_lambda_function.function.function_name
}
