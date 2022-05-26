
data "aws_availability_zones " "azs" {
  state = "available"
}

module "vpc" {
  source = "../Modules/Network"

  env = var.environment
  app = var.application

  vpc_cidr = var.vpc_cidr
  public_cidr = var.public_cidrs
  private_cidr = var.private_cidrs
  azs = data.aws_availability_zones.azs.names
  # azs = ["ap-southeast-1a", "ap-southeast-1b"]

  # Tài nguyên FARGATE được đặt tại Private subnet, vì thế bật NAT Gateway
  enable_nat_gateway = var.enable_nat_gateway
  create_1_nat_gateway_on_1_AZ = var.nat_gateway_on_1_AZ
}

module "role" {
  source = "../Modules/Gobal/IAM"

  # IAM Role for ECS Service (AWSServiceRoleForECS)
  ecs_service_role_name = "terraform-ecsServiceRole"
  ecs_service_identifiers = ["ecs.amazonaws.com"]
  ecs_service_policy_name = "terraform-ecsServicePolicy"

  # IAM Role for execute ECS Task (AmazonECSTaskExecutionRolePolicy)
  ecs_exec_task_role_name = "terraform-ecsTaskExecuteRole"
  ecs_exec_task_identifiers = ["ecs-tasks.amazonaws.com"]
  ecs_exec_task_policy_name = "terraform-ecsTaskExecutePolicy"

  # IAM Role for Lambda Function (to trigger CodeBuild)
}

module "ecr" {
  source = "../Modules/ECR"

  repo_name = var.ecr_repo_name

  # Cho phép khả năng ghi đè tags?
  image_tag_setting = var.image_tag_setting

  # Scan iamge on Repo
  scan_on_push = true
}

# -- Port 80 dành cho môi trường ban đầu - BLUE
# -- Port 9090 dành cho môi trường revision source - GREEN
# -- Hai môi trường đều có Target lắng nghe trên port 80 (và các Container trong đó lắng nghe trên port 8080)

module "alb" {
  source = "../Modules/LB"

  vpc_id = module.vpc.vpc_id

  fargate = true

  # Target
  name_target_group = "terraform-target-group"
  targetgroup_port = 80
  targetgroup_protocol = "HTTP"
  targetgroup_type = "ip" //for Launch_type FARGATE

  # Target for Green Deployment
  use_pipline = true //--> add ingress rule: Allow port 9090
  name_green_target_group = "terraform-green-target-group"
  green_target_port = 80
  green_target_protocol = "HTTP"

  # ALB
  name_alb = "terraform-alb"
  lb_type = "application"
  internal = false
  subnets_id = module.vpc.public_subnet_id //all subnet

  # Listener
  listener_port = 80
  listener_protocol = "HTTP"
  action_type = "forward"

  # Listener for Green Deployment
  //use_pipline = true
  green_listener_port = 9090
  green_listener_protocol = "HTTP"
}

module "container_task_logging" {
  source = "../Modules/Gobal/Cloudwatch Logs"

  logs_group_name = "/ecs/task-test__fargate/container"
  logs_stream_name = "terraform-logs-for-task-test__fargate-"
}

data "template_file" "container_definitions" {
  template = file("../Local Repostory/files-container-definitions/container_definitions__fargate.json")

  vars = {
    message = var.container_definitions_message
    logs_group = "${module.container_task_logging.logs_group_name}"
    logs_stream = "${module.container_task_logging.logs_stream_name}"
    account_id = var.acc_id
    region = var.region
    repo = var.repo_image
    
    # Khi source thay đổi trên CodeCommit, CodeBuild sẽ push image mới lên với 2 tag 'latest' & 'id_commit'
    # ECR được cấu hình "IMMUTABLE" - để ngăn ghi đè image mới có tag 'latest' với image cũ, lúc này tag của image cũ sẽ chỉ là 'id_commit' đặt trước đó
    tags = var.tag_image //(latest) lấy image version mới nhất có trong ECR
  }
}

resource "aws_security_group" "sg_service" {  
  name = "terraform-sg-ecs-service"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = [module.alb.sg_alb_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  service_count = 2 //chỉ định số lượng Instance để đặt các Task?

  # SG for ECS Service
  sg_ecs_service = aws_security_group.sg_service.id
  # vpc_id = module.vpc.vpc_id
  # sg_alb_id = module.alb.sg_alb_id

  # Enable Network configuration
  private_subnets = module.vpc.private_subnet_id //list

  # LB configuration
  targetgroup_arn = "${module.alb.targetgroup_arn}"
  container_name = "terraform"
  container_port = 8080

  # LB configuration for Green Deployment
  use_pipline = true
  green_target_arn = "${module.alb.green_target_arn}"
  green_containers_name = "terraform"
  green_containers_port = 8080

  # Revison Source (CD with CodeDeploy)
  revision_source = true
  deployment_controller_type = "CODE_DEPLOY"
  
  depends_on = [ module.container_task_logging ]
}

