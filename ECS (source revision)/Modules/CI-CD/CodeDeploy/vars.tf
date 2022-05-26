
variable "deploy_app_ecs_name" {
  type = string
}

variable "deploy_ecs_platform" {
  type = string
}

# --------------------------------------

variable "deployment_config_ecs" {
  type = string
}

variable "deployment_group_ecs_name" {
  type = string
}

variable "codedeploy_for_ecs_role_arn" {
  type = string
}

# --------------------------------------

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

# --------------------------------------

variable "listener_arns" {
  type = list
}

variable "blue_target_name" {
  type = string
}

variable "green_target_name" {
  type = string
}
