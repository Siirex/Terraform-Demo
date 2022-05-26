
/*
variable "event_codebuild_rule_name" {
  type = string
}

variable "source_codebuild_events" {
  type = string
}

variable "detail_codebuild_type" {
  type = string
}

variable "build_status" {
  type = string
}

variable "build_project_name" {
  type = string
}

variable "role_sns_event" {
  type = string
}

variable "trigger_sns" {
  type = string
}

variable "trigger_sns_arn" {
  type = string
}
*/

# --------------------------------------

variable "enable_events" {
  type = bool
}

variable "event_ecr_rule_name" {
  type = string
}

variable "source_ecr_events" {
  type = string
}

variable "detail_ecr_type" {
  type = string
}

variable "repo_ecr_name" {
  type = string
}

variable "action_event" {
  type = string
}

variable "result_event" {
  type = string
}

variable "image-tag" {
  type = string
}

# ----------------------------------

variable "trigger_ecs" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "role_ecs_event" {
  type = string
}

variable "task_count" {
  type = string
}

variable "taskdef_arn" {
  type = string
}

variable "launch_type" {
  type = string
}

variable "platform_version" {
  type = string
}

variable "assign_public_ip" {
  type = bool
}

variable "ecs_sgs" {
  type = list
}

variable "subnets" {
  type = list
}
