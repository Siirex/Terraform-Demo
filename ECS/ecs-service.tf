
# Định nghĩa Task nào nên được sử dụng để khởi chạy một Container và ALB nào (TargetGroup + Listener) nên được liên kết với Container đó.


# ECS Service for 'task_test':
resource "aws_ecs_service" "service_test" {
  name = "terraform-ecs-service-for-task-test"

  cluster = aws_ecs_cluster.cluster.id
  task_definition = "${aws_ecs_task_definition.task_test.family}:${data.aws_ecs_task_definition.default.revision}"
  
  launch_type = "EC2"
  
  # Tùy vào số lượng Instance của Task Definition để đặt
  # Cụ thể, ta chỉ muốn chạy 1 Instance chứa 'task-test' (dùng >2 để đảm bảo ứng dụng luôn được backup)
  desired_count = 1

  # Permission for ECS Service
  iam_role = aws_iam_role.ecs_service.arn

  enable_ecs_managed_tags = true
  force_new_deployment = true //deployment sẽ bị bắt buộc, 

  # Liên kết TargetGroup chứa Container 'terraform' với ECS Service
  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name = "terraform"
    container_port = 8080 //request được ECS Service forward từ TargetGroup đến port 8080 của Container chạy trong đó
  }

  depends_on = [ aws_lb_listener.alb, aws_iam_role_policy_attachment.ecs_service ]
}


# ECS Service for 'task_test__fargate':
resource "aws_ecs_service" "service_test__fargate" {
  name = "terraform-ecs-service-for-task-test__fargate"

  cluster = aws_ecs_cluster.cluster.id
  task_definition = "${aws_ecs_task_definition.task_test__fargate.family}:${data.aws_ecs_task_definition.default__fargate.revision}"
  
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA" //???
  desired_count = 1

  # Permission for ECS Service
  iam_role = aws_iam_role.ecs_service.arn

  enable_ecs_managed_tags = true
  force_new_deployment = true

  # Vì khi sử dụng FARGATE, AWS cung cấp các tài nguyên môi trường để các Task/container chạy trên đó
  # Nghĩa là sẽ không còn tài nguyên ASG Instances như trong thiết lập Launch_type EC2
  # Do đó, thay vì sử dụng các Instances, ta chỉ cần khai báo cấu hình Network (subnet, sg) như sau:
  network_configuration {
    subnets = aws_subnet.private.*.id //cấu hình được đặt tại Private Subnets (không NAT Gateway, không cần truy cập Internet)
    security_groups = [ aws_security_group.alb.id, aws_security_group.ecs_cluster.id ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name = "terraform"
    container_port = 8080
  }

  depends_on = [ aws_lb_listener.alb, aws_iam_role_policy_attachment.ecs_service ]
}
