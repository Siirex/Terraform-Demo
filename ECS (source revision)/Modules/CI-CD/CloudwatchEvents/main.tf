
# Rule for Codebuild - trigger SNS Topic
/*
resource "aws_cloudwatch_event_rule" "codebuild" {
  name = var.event_codebuild_rule_name
  is_enabled = var.enable_events

  event_pattern = <<EOF
{
  "source": ["${var.source_codebuild_events}"],
  "detail-type": ["${var.detail_codebuild_type}"],
  "detail": {
    "build-status": ["${var.build_status}"],
    "project-name": ["${var.build_project_name}"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "trigger_sns" {
  rule = aws_cloudwatch_event_rule.codebuild.name

  role_arn = var.role_sns_event
  target_id = var.trigger_sns
  arn = var.trigger_sns_arn
}
*/

# Rule for ECR - trigger ECS Service
resource "aws_cloudwatch_event_rule" "ecr" {
  name = var.event_ecr_rule_name
  is_enabled = var.enable_events

  event_pattern = <<EOF
{
  "source": ["${var.source_ecr_events}"], 
  "detail-type": ["${var.detail_ecr_type}"], 
  "detail": {
    "repository-name": ["${var.repo_ecr_name}"],
    "action-type": ["${var.action_event}"], 
    "result": ["${var.result_event}"], 
    "image-tag": ["${var.image-tag}"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "trigger_ecs_service" {
  rule = aws_cloudwatch_event_rule.ecr.name

  role_arn = var.role_ecs_event
  target_id = var.trigger_ecs
  arn = var.ecs_cluster_arn

  ecs_target {
    task_count = var.task_count
    task_definition_arn = var.taskdef_arn
    launch_type = var.launch_type
    platform_version = var.platform_version

    network_configuration {
      assign_public_ip = var.assign_public_ip
      security_groups = var.ecs_sgs
      subnets = var.subnets
    }
  }
}




