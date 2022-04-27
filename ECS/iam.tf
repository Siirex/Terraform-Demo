
# --------------------------------------------------------------------------------------
# IAM Role for ECS Container Instance
# --------------------------------------------------------------------------------------
# Trong ECS Container Instance (EC2), khi chạy các Container Agent cần IAM Role để dịch 
# ... vụ ECS biết rằng Agent đó thuộc về Account hiện hành!!!
# Policy "AmazonEC2ContainerServiceforEC2Role" chứa các permission cần thiết để sử dụng
# ... các tính năng của dịch vụ ECS!!!
# IAM Role này sẽ được liên kết với Container Instance (EC2) 
# --------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_container_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_container_instance" {
  assume_role_policy = data.aws_iam_policy_document.ecs_container_instance.json
  name = "terraform-ecsInstanceRole" //default name on AWS Console
}

# Cấp quyền truy cập vào các tài nguyên mà ECS cần xử lý để chạy ứng dụng:
resource "aws_iam_policy" "ecs_container_instance" {
  name = "terraform-ecsInstancePolicy"
  
  # AmazonEC2ContainerServiceforEC2Role
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeTags",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

/*
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "cloudwatch:*",
        "s3:*",
        "rds:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
*/

resource "aws_iam_role_policy_attachment" "ecs_container_instance" {
  role = aws_iam_role.ecs_container_instance.name
  policy_arn = aws_iam_policy.ecs_container_instance.arn
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_container_instance" {
  name = "terraform-ecsInstanceProfile"
  role = aws_iam_role.ecs_container_instance.name
}


# ------------------------------------------------------------------------------------
# IAM Role for ECS Service
# ------------------------------------------------------------------------------------
# Cấp các quyền để ECS Service gọi các tài nguyên khác
# ------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_service" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_service" {
  assume_role_policy = data.aws_iam_policy_document.ecs_service.json
  name = "terraform-ecsServiceRole"
}

resource "aws_iam_policy" "ecs_service" {
  name = "terraform-ecsServicePolicy"
  path = "/"

  # AWSServiceRoleForECS (more permission)
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role = aws_iam_role.ecs_service.name
  policy_arn = aws_iam_policy.ecs_service.arn
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AWSServiceRoleForECS"
}

# ------------------------------------------------------------------------------------
# IAM Role for execute ECS Task (AmazonECSTaskExecutionRolePolicy)
# ------------------------------------------------------------------------------------
# Cấp cho ECS Container và Fargate agents - quyền thực hiện lệnh gọi các tài nguyên khác
# Các permission sẽ tùy thuộc vào yêu cầu của Task:
# -- Task nằm trên Fargate / External Instance cần:
# -- -- Pull Image từ ECR Repo
# -- -- Logging Container tới CloudWatch Logs bằng "awslogs"
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
# ------------------------------------------------------------------------------------

data "aws_iam_policy_document" "exec_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "exec_task" {
  assume_role_policy = data.aws_iam_policy_document.exec_task.json
  name = "terraform-ecsTaskExecuteRole" //default name on AWS Console
}

resource "aws_iam_policy" "exec_task" {
  name = "terraform-ecsTaskExecutePolicy"
  path = "/"

  # AmazonECSTaskExecutionRolePolicy
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "exec_task" {
  role = aws_iam_role.exec_task.name
  policy_arn = aws_iam_policy.exec_task.arn
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------------------------------------------------------------
# IAM Role for ECS Task
# ------------------------------------------------------------------------------------
# Các permission được cấp cho các Container đang run trong Task
# IAM Role sẽ áp dụng cho Task Definition
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
# ------------------------------------------------------------------------------------

data "aws_iam_policy_document" "task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "task" {
  assume_role_policy = data.aws_iam_policy_document.task.json
  name = "terraform-ecsTaskRole" //default name on AWS Console
}

resource "aws_iam_policy" "task" {
  name = "terraform-ecsTaskPolicy"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "..."
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task" {
  role = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task.arn
}
