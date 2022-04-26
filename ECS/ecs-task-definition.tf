
resource "aws_cloudwatch_log_group" "task_test" {
  name = "terraform-logs-for-task-test"
}

data "template_file" "container_definitions" {
  template = file("${path.root}/container_definitions.json")

  vars = {
    message = var.container_definitions_message
    account_id = var.acc_id
    region = var.regionn
    tags = var.tag_image
    repo = var.repo_image
  }
}

# Task Definition with Launch types is 'EC2' (on Public Subnets)
resource "aws_ecs_task_definition" "task_test" {
  family = "task-test"
  container_definitions = data.template_file.container_definitions.rendered //container

  requires_compatibilities = ["EC2"] //các tài nguyên (Instances - môi trường chứa các Task) được Custom tạo và quản lý!

  # IAM Role for Task
  execution_role_arn = aws_iam_role.ecs.arn //cấp quyền 'task execution' cho Container agent
  task_role_arn = aws_iam_role.ecs.arn //cho phép Task Container thực hiện call đến các dịch vụ AWS khác

  # Chỉ định dung lượng tài nguyên cho Task trong mỗi Instnace của ECS Cluster:
  memory = 500
  network_mode = "host"
  # network_mode = "bridge" //nếu chạy nhiều Task cho App vào cùng 1 Container

  depends_on = [ aws_cloudwatch_log_group.task_test ]
}

# Tìm nạp bản sửa đổi Task Definition hoạt động mới nhất (áp dụng cho trường hợp sửa đổi nó)
data "aws_ecs_task_definition" "default" {
  task_definition = aws_ecs_task_definition.task_test.family
}


# ------------------------------------------------------------

resource "aws_cloudwatch_log_group" "task_test__fargate" {
  name = "terraform-logs-for-task-test__fargate"
}

data "template_file" "container_definitions__fargate" {
  template = file("${path.root}/container_definitions__fargate.json")

  vars = {
    message = var.container_definitions_message
    account_id = var.acc_id
    region = var.regionn
    tags = var.tag_image
    repo = var.repo_image
  }
}

# Task Definition with Launch types is 'FARGATE' (on Private Subnets)
resource "aws_ecs_task_definition" "task_test__fargate" {
  family = "task-test__fargate"
  container_definitions = data.template_file.container_definitions__fargate.rendered

  requires_compatibilities = ["FARGATE"] //các tài nguyên (Instances - môi trường chứa các Task) được AWS cung cấp và quản lý!

  execution_role_arn = aws_iam_role.ecs.arn
  task_role_arn = aws_iam_role.ecs.arn

  # Chỉ định dung lượng tài nguyên cho Task trong các tài nguyên (được AWS cung cấp) của ECS Cluster:
  cpu = 256 //required for FARGATE
  memory = 512 //required for FARGATE
  network_mode = "awsvpc"

  depends_on = [ aws_cloudwatch_log_group.task_test ]
}

data "aws_ecs_task_definition" "default__fargate" {
  task_definition = aws_ecs_task_definition.task_test__fargate.family
}
