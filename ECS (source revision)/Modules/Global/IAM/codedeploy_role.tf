
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/codedeploy_IAM_role.html

resource "aws_iam_role" "codedeploy" {
  # assume_role_policy = data.aws_iam_policy_document.codedeploy.json
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "codedeploy.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
  name = "terraform_iam_role_codedeploy"
}

/*
data "aws_iam_policy_document" "codedeploy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [ "codedeploy.amazonaws.com" ]
      type = "Service"
    }
  }
}
*/

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  # policy_arn = aws_iam_policy.codedeploy.arn #AWSCodeDeployRoleForECS
}

resource "aws_iam_role_policy" "codedeploy" {
  name = "terraform_iam_role_policy_codedeploy"
  role = aws_iam_role.codedeploy.name
  
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/codedeploy_IAM_role.html
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "ecs:DescribeServices",
            "ecs:CreateTaskSet",
            "ecs:UpdateServicePrimaryTaskSet",
            "ecs:DeleteTaskSet",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadýebalancing:DescribeListeners",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:ModifyRule",
            "lambda:InvokeFunction",
            "cloudwatch:DescribeAlarms",
            "sns:Publish",
            "s3:GetObject",
            "s3:GetObjectVersion"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "iam:PassedToService": [
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      }
    ]
})
}


