
output "invoke_url" {
  value = aws_apigatewayv2_stage.api_igw.invoke_url
}

output "function_list_name" {
  value = aws_lambda_function.list.function_name
}

output "function_create_name" {
  value = aws_lambda_function.create.function_name
}
