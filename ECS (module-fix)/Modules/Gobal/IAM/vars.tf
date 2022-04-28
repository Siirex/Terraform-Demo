
variable "ecs_container_instance_role_name" {
  type = string
}

variable "container_instance_identifiers" {
  type = list()
}

variable "ecs_container_instance_policy_name" {
  type = string
}

# -----------------------------------------------------

variable "ecs_container_instance_iam_profile_name" {
  type = string
}

# -----------------------------------------------------

variable "ecs_service_role_name" {
  type = string
}

variable "ecs_service_identifiers" {
  type = list()
}

variable "ecs_service_policy_name" {
  type = string
}

# -----------------------------------------------------

variable "ecs_exec_task_role_name" {
  type = string
}

variable "ecs_exec_task_identifiers" {
  type = list()
}

variable "ecs_exec_task_policy_name" {
  type = string
}


