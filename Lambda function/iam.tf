
# -------------------------------------------------------------------------------------------------------------------------
# IAM Role for Lambda (logging call function)
# -------------------------------------------------------------------------------------------------------------------------

# Cho phép Lambda truy cập các tài nguyên trong tài khoản AWS
resource "aws_iam_role" "lambda_role" {
  name = "terraform_lambda_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Cho phép Lambda logging trên các Services giám sát Log
resource "aws_iam_policy" "lambda_policy" {
  name = "terraform_lambda_policy"
  path = "/"
  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" //Policy (có sẵn trên AWS) cho phép Function logging vào CloudWatch Logs
  policy_arn = aws_iam_policy.lambda_policy.arn
  role = aws_iam_role.lambda_role.id
}



# -------------------------------------------------------------------------------------------------------------------------
# IAM Role for API Gateway (logging call integration & invoke permission)
# -------------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "api_igw" {
  name = "Allow_logging_API_Gateway"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "api_igw_policy" {
  name = "terraform_api_igw_policy"
  path = "/"
  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
   {
     "Action": [
       "lambda:InvokeFunction"
     ],
     "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_igw" {
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  policy_arn = aws_iam_policy.api_igw_policy.arn
  role = aws_iam_role.api_igw.id
}

