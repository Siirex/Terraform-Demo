
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name

  # Đảm bảo thông tin chi tiết về container được bật trên Cluster
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "task" {
  family = var.task_name
  container_definitions = var.file_container_definitions

  requires_compatibilities = var.requires_compatibilities

  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn

  cpu = var.fargate ? var.task_cpu : null
  memory = var.task_memory
  network_mode = var.network_mode
}

data "aws_ecs_task_definition" "default" {
  task_definition = aws_ecs_task_definition.task.family
}

resource "aws_security_group" "sg_service" {
  count = var.fargate ? 1 : 0
  
  name = "terraform-sg-ecs-service"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = ["${var.sg_alb_id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "service" {
  name = var.ecs_service_name

  cluster = aws_ecs_cluster.cluster.id
  task_definition = "${aws_ecs_task_definition.task.family}:${data.aws_ecs_task_definition.default.revision}" //example, task-test:1
  
  launch_type = var.launch_type
  
  desired_count = var.service_count

  # Permission for ECS Service
  iam_role = var.fargate ? null : var.service_role

  enable_ecs_managed_tags = true
  force_new_deployment = true //deployment sẽ bị bắt buộc, 
  
  dynamic "network_configuration" {
    for_each = var.fargate == true ? [1] : []
    content {
      subnets = var.private_subnets
      # security_groups = var.sg_setting
      security_groups = [ aws_security_group.sg_service.0.id ]
    }
  }

  # Liên kết TargetGroup chứa Container 'terraform' với ECS Service
  load_balancer {
    target_group_arn = var.targetgroup_arn
    container_name = var.container_name
    container_port = var.container_port
  }
}
