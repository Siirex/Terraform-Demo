
# Cho phép dịch vụ ECS lấy Image từ ECR Repo:
data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs" {
  assume_role_policy = data.aws_iam_policy_document.ecs.json
  name = "ecsInstanceRole" //default name on AWS Console
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role = aws_iam_role.ecs.name
  # Cấp quyền truy cập vào các tài nguyên mà ECS cần xử lý để chạy ứng dụng
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs.name
}

# ------------------------------------------------------------------------------------

resource "aws_iam_policy" "logs" {
  name = "terraform_container_logs_policy"
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

resource "aws_iam_role_policy_attachment" "logs" {
  role = aws_iam_role.ecs.name
  policy_arn = aws_iam_policy.logs.arn
}
