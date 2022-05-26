
variable "ecs_cluster_name" {
  type = string
}

# ----------------------------------

variable "task_name" {
  type = string
}

variable "file_container_definitions" {
}

variable "requires_compatibilities" {
  type = list()
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "fargate" {
  type = bool
}

variable "task_cpu" {
  type = string
  default = "" //call module nó sẽ ghi đè (để giá trị gì cũng được)
}

variable "task_memory" {
  type = string
}

variable "network_mode" {
  type = string
}

# ----------------------------------

variable "ecs_service_name" {
  type = string
}

variable "launch_type" {
  type = string
}

variable "service_count" {
  type = number
}

variable "service_role" {
  type = string
  default = ""
}

/*
variable "vpc_id" {
  type = string
  default = ""
}

variable "sg_alb_id" {
  type = string
  default = ""
}
*/

variable "sg_ecs_service" {
  type = string
}

variable "private_subnets" {
  type = list
  default = []
}

/*
variable "sg_setting" {
  type = list
  default = []
}
*/

variable "targetgroup_arn" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

# ---------------------------------------------

variable "revision_source" {
  type = bool
}

variable "deployment_controller_type" {
  type = string
  default = ""
}

variable "use_pipline" {
  type = bool
}

variable "green_target_arn" {
  type = string
  default = ""
}

variable "green_containers_name" {
  type = string
  default = ""
}

variable "green_containers_port" {
  type = string
  default = ""
}
