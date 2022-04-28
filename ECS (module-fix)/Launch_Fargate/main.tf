
module "vpc" {
  source = "../Modules/Network"

  env = var.environment
  app = var.application

  vpc_cidr = "10.1.0.0/16"
  public_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
  private_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
  azs = ["ap-southeast-1a", "ap-southeast-1b"]

  # Vì dùng ECS Service với Lauch_type là "Fargate"
  # Nên tài nguyên sẽ được đặt tại Private subnet, vì thế cần bật NAT Gateway
  enable_nat_gateway = true
  create_1_nat_gateway_on_1_AZ = true
}

module "role" {
  source = "../Modules/Gobal/IAM"

  # IAM Role for ECS Container Instance (AmazonEC2ContainerServiceforEC2Role)
  ecs_container_instance_role_name = "terraform-ecsInstanceRole" //default name on AWS Console
  container_instance_identifiers = ["ec2.amazonaws.com"]
  ecs_container_instance_policy_name = "terraform-ecsInstancePolicy"

  # IAM Container Instance Profile
  ecs_container_instance_iam_profile_name = "terraform-ecsInstanceProfile"

  # IAM Role for ECS Service (AWSServiceRoleForECS)
  ecs_service_role_name = "terraform-ecsServiceRole"
  ecs_service_identifiers = ["ecs.amazonaws.com"]
  ecs_service_policy_name = "terraform-ecsServicePolicy"

  # IAM Role for execute ECS Task (AmazonECSTaskExecutionRolePolicy)
  ecs_exec_task_role_name = "terraform-ecsTaskExecuteRole"
  ecs_exec_task_identifiers = ["ecs-tasks.amazonaws.com"]
  ecs_exec_task_policy_name = "terraform-ecsTaskExecutePolicy"
}

module "ecr" {
  source = "../Modules/ECR"

  repo_name = "terraform"

  # Khả năng thay đổi Tags
  image_tag_setting = "IMMUTABLE"

  # Scan iamge on Repo
  scan_on_push = true
}

module "alb" {
  source = "../Modules/LB"

  name_target_group = "terraform-target-group"
  vpc_id = module.vpc.vpc_id

  fargate = true

  targetgroup_port = 80
  targetgroup_protocol = "HTTP"
  target_type = "ip" //for Launch_type FARGATE

  name_alb = "terraform-alb"
  lb_type = "application"
  internal = false
  subnets_id = module.vpc.public_subnet_id //all subnet

  listener_port = 80
  listener_protocol = "HTTP"
  action_type = "forward"
}

module "container_task_logging" {
  source = "../Modules/Gobal/Cloudwatch Logs"

  logs_group_name = "/ecs/task-test__fargate/container"
  logs_stream_name = "terraform-logs-for-task-test__fargate-"
}

data "template_file" "container_definitions" {
  template = file("../files-container-definitions/container_definitions__fargate.json")

  vars = {
    message = var.container_definitions_message
    logs_group = "${module.container_task_logging.logs_group_name}"
    logs_stream = "${module.container_task_logging.logs_stream_name}"
    account_id = var.acc_id
    region = var.region
    tags = var.tag_image
    repo = var.repo_image
  }
}

module "ecs" {
  source = "../Modules/ECS"

  ecs_cluster_name = "stage-test__fargate"

  task_name = "task-test__fargate"
  file_container_definitions = "${data.template_file.container_definitions.rendered}"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = module.role.ecs_task_exec_role_arn
  task_role_arn = module.role.ecs_task_exec_role_arn //dùng chung permission với Task Execute Role

  fargate = true

  task_cpu = "256"
  task_memory = "512"
  network_mode = "awsvpc"

  ecs_service_name = "terraform-ecs-service-for-task-test__fargate"
  launch_type = "FARGATE"
  service_count = 2 //chỉ định số lượng Task chạy backup (đáp ứng khả năng sẵn sàng của các Container chạy trong đó)

  # Nếu áp dụng FARGATE, không cần add Role cho ECS Service nữa, vì đã có SG!!!
  # service_role = module.role.ecs_ecs_role_arn

  # SG for ECS Service
  vpc_id = module.vpc.vpc_id
  sg_alb_id = module.alb.sg_alb_id

  # Enable Network configuration
  private_subnets = module.vpc.private_subnet_id //list

  # LB configuration
  targetgroup_arn = "${module.alb.targetgroup_arn}"
  container_name = "terraform"
  container_port = 8080

  depends_on = [ module.container_task_logging, module.role ]
}
