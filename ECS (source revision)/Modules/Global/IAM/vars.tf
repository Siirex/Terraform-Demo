
# -----------------------------------------------------

variable "ecs_service_role_name" {
  type = string
}

variable "ecs_service_identifiers" {
  type = list
}

variable "ecs_service_policy_name" {
  type = string
}

# -----------------------------------------------------

variable "ecs_exec_task_role_name" {
  type = string
}

variable "ecs_exec_task_identifiers" {
  type = list
}

variable "ecs_exec_task_policy_name" {
  type = string
}

# ----------------------------------------------------

variable "artifact_encryption_key_arn" {
  type = string
  default = ""
}

variable "build_artifact_bucket_arn" {
  type = string
  default = ""
}
