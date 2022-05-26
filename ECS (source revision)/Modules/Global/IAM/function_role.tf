
# ---------------------------------------------------------------
# IAM Role for Funtcion Log
# -- Allow Lambda access Cloudwatch Logs
# -- Allow SNS topic calling Lambda function (used aws_lambda_permission)

resource "aws_iam_role" "function_logs" {
  assume_role_policy = data.aws_iam_policy_document.function_logs.json
  name = "terraform_iam_role_function_logs"
}

data "aws_iam_policy_document" "function_logs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [ "lambda.amazonaws.com" ]
      type = "Service"
    }
  }
}

resource "aws_iam_policy" "function_logs" {
  name = "terraform_iam_policy_function_logs"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:GetLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
})
}

resource "aws_iam_role_policy_attachment" "function_logs" {
  role = aws_iam_role.function_logs.name
  policy_arn = aws_iam_policy.function_logs.arn #AWSLambdaBasicExecutionRole
}

# -----------------------------------------------------------
# IAM Role for Function Build
# -- Allow Lambda calling CodeBuild
# -- Allow CodeCommit trigger Lambda function

resource "aws_iam_role" "function_build" {
  assume_role_policy = data.aws_iam_policy_document.function_build.json
  name = "terraform_iam_role_function_build"
}

data "aws_iam_policy_document" "function_build" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [ "lambda.amazonaws.com" ]
      type = "Service"
    }
  }
}

# Policy "AWSCodeBuildDeveloperAccess" cho phép truy cập tất cả các chức năng của CodeBuild
resource "aws_iam_policy" "function_build" {
  name = "terraform_iam_policy_function_build"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:StartBuildBatch",
          "codebuild:StopBuildBatch",
          "codebuild:RetryBuild",
          "codebuild:RetryBuildBatch",
          "codebuild:BatchGet*",
          "codebuild:GetResourcePolicy",
          "codebuild:DescribeTestCases",
          "codebuild:DescribeCodeCoverages",
          "codebuild:List*",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:ListBranches",
          "cloudwatch:GetMetricStatistics",
          "events:DescribeRule",
          "events:ListTargetsByRule",
          "events:ListRuleNamesByTarget",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets"
        ],
        "Resource": "*"
      }
    ]
})
}

resource "aws_iam_role_policy_attachment" "function_build" {
  role = aws_iam_role.function_build.name
  policy_arn = aws_iam_policy.function_build.arn #AWSCodeBuildDeveloperAccess
  # https://docs.aws.amazon.com/codebuild/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html#developer-access-policy
}


# Nếu 2 Lambda function nằm trong VPC, ta cần Role như sau:
/*
resource "aws_iam_role_policy_attachment" "vpc_attachment" {
  role  = aws_iam_role.function_logs.name // & aws_iam_role.function_build.name

  // see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
*/
