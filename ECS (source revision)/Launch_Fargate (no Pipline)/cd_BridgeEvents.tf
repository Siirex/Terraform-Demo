
module "events_brigde" {
  source = "../Modules/CI-CD/CloudwatchEvents"

  enable_events = true

  # Bắt các Events từ CodeBuild, sau đó trigger 1 SNS Topic để notification với Developer
  /*
  event_codebuild_rule_name = "terraform_codebuild_events"
  source_codebuild_events = "aws.codebuild"
  detail_codebuild_type = "CodeBuild Build State Change"
  build_status = "SUCCEEDED"
  build_project_name = module.codebuild.build_project_name

  role_sns_event = module.role.role_sns_eventbridge
  trigger_sns = "SNSTopic"
  trigger_sns_arn = module.sns.topic_arn
  */

  # Bắt các Events từ ECR (với action PUSH), sau đó trigger ECS Cluster / Service (auto update & running new Task)
  event_ecr_rule_name = "terraform_ecr_events"
  source_ecr_events = "aws.ecr"
  detail_ecr_type = "ECR Image Action"
  repo_ecr_name = var.ecr_repo_name
  action_event = "PUSH"
  result_event = "SUCCESS"
  image-tag = "latest"

  role_ecs_event = module.role.role_ecs_eventbridge
  trigger_ecs = "ECStask"
  ecs_cluster_arn = module.ecs.ecs_cluster_arn
  
  task_count = 1
  taskdef_arn = module.ecs.ecs_taskdef_arn
  launch_type = "FARGATE"
  platform_version = "LATEST"
  assign_public_ip = false
  ecs_sgs = [ aws_security_group.sg_service.id ]
  subnets = module.vpc.private_subnet_id
}

