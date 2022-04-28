
# --------------------------------------------------------------------------------------
# IAM Role for ECS Container Instance
# --------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecscontainer_instance_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = var.container_instance_identifiers
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecscontainer_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ecscontainer_instance_role.json
  name = var.ecs_container_instance_role_name
}

resource "aws_iam_policy" "ecscontainer_instance_role" {
  name = var.ecs_container_instance_policy_name
  
  # AmazonEC2ContainerServiceforEC2Role
  policy = jsonencode({
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
})
}

resource "aws_iam_role_policy_attachment" "ecscontainer_instance_role" {
  role = aws_iam_role.ecscontainer_instance_role.name
  policy_arn = aws_iam_policy.ecscontainer_instance_role.arn
}

# IAM Container Instance Profile
resource "aws_iam_instance_profile" "profile" {
  name = var.ecs_container_instance_iam_profile_name
  role = aws_iam_role.ecscontainer_instance_role.name
}

# --------------------------------------------------------------------------------------
# IAM Role for ECS Service
# --------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = var.ecs_service_identifiers
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_service_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_service_role.json
  name = var.ecs_service_role_name
}

resource "aws_iam_policy" "ecs_service_role" {
  name = var.ecs_service_policy_name
  
  # AWSServiceRoleForECS
  policy = jsonencode({
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
})
}

resource "aws_iam_role_policy_attachment" "ecs_service_role" {
  role = aws_iam_role.ecs_service_role.name
  policy_arn = aws_iam_policy.ecs_service_role.arn
}

# --------------------------------------------------------------------------------------
# IAM Role for execute ECS Task
# --------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_task_exec_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = var.ecs_exec_task_identifiers
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_task_exec_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_role.json
  name = var.ecs_exec_task_role_name
}

resource "aws_iam_policy" "ecs_task_exec_role" {
  name = var.ecs_exec_task_policy_name
  
  # AmazonECSTaskExecutionRolePolicy
  policy = jsonencode({
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
})
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role" {
  role = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.ecs_task_exec_role.arn
}














