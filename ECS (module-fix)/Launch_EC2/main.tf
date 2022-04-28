
module "vpc" {
  source = "../Modules/Network"

  env = var.environment
  app = var.application

  vpc_cidr = "10.1.0.0/16"
  public_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
  private_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
  azs = ["ap-southeast-1a", "ap-southeast-1b"]

  # Vì dùng ECS Service với Lauch_type là "EC2"
  # Nên tài nguyên sẽ được đặt tại public subnet, vì thế không cần bật NAT Gateway
  enable_nat_gateway = false
  create_1_nat_gateway_on_1_AZ = false
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

# Public Key for Instance of Cluster
resource "aws_key_pair" "key" {
  key_name = "terraform-key"
  public_key = "${file("key-access-instances.pub")}"
}

data "template_file" "userdata_container_instance" {
  template = file("${path.root}/provision.sh")
  vars = {
    ecs_cluster_name = "${module.ecs.ecs_cluster_name}"
  }
}

module "container_instances" {
  source = "../Modules/ASG"

  ami_ecs_instance = "amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"
  name_prefix_launch_configuration = "terraform-launch-"
  container_instance_type = "t2.micro"
  public_key_name = "${aws_key_pair.key.key_name}"
  container_user_data = "${data.template_file.userdata_container_instance.rendered}"
  vpc_id = module.vpc.vpc_id
  associate_public_ip = true
  iam_profile = module.role.iam_profile

  name_asg = "terraform-container-instances"
  desired_capacity = 1
  min_container = 1
  max_container = 1
  healthcheck_type = "EC2"
  subnets_id = module.vpc.public_subnet_id //all subnet
}

module "alb" {
  source = "../Modules/LB"

  name_target_group = "terraform-target-group"
  vpc_id = module.vpc.vpc_id

  targetgroup_port = 80
  targetgroup_protocol = "HTTP"
  targetgroup_type = "instance" //for Launch_type EC2

  # Attachment ASG with TargetGroup
  asg_id = module.container_instances.asg_id

  name_alb = "terraform-alb"
  lb_type = "application"
  internal = false
  subnets_id = module.vpc.public_subnet_id //all subnet

  listener_port = 80
  listener_protocol = "HTTP"
  action_type = "forward"

  depends_on = [ module.container_instances ]
}

# Allow HTTP request to ECS Container form ALB
resource "aws_security_group_rule" "container_instance" {
  security_group_id = module.container_instances.sg_container_instance_id
  type = "ingress"

  from_port = 0
  to_port = 65535
  protocol = "tcp"
  source_security_group_id = "${module.alb.sg_alb_id}"
}

module "container_task_logging" {
  source = "../Modules/Gobal/Cloudwatch Logs"

  logs_group_name = "/ecs/task-test/container"
  logs_stream_name = "terraform-logs-for-task-test-"
}

data "template_file" "container_definitions" {
  template = file("../files-container-definitions/container_definitions.json")

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

  ecs_cluster_name = "stage-test"

  task_name = "task-test"
  file_container_definitions = "${data.template_file.container_definitions.rendered}"
  requires_compatibilities = ["EC2"]

  execution_role_arn = module.role.ecs_task_exec_role_arn
  task_role_arn = module.role.ecs_task_exec_role_arn //dùng chung permission với Task Execute Role

  fargate = false

  task_memory = "500"
  network_mode = "host"

  ecs_service_name = "terraform-ecs-service-for-task-test"
  launch_type = "EC2"

  service_count = 1

  service_role = module.role.ecs_ecs_role_arn

  # LB configuration
  targetgroup_arn = "${module.alb.targetgroup_arn}"
  container_name = "terraform"
  container_port = 8080

  depends_on = [ module.container_task_logging, module.role ]
}
