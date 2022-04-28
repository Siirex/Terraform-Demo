
variable "name_target_group" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "targetgroup_port" {
  type = number
}

variable "targetgroup_protocol" {
  type = string
}

variable "targetgroup_type" {
  type = string
}

# -------------------------------

variable "fargate" {
  type = bool
}

variable "asg_id" {
  type = string
  default = ""
}

# -------------------------------

variable "name_alb" {
  type = string
}

variable "lb_type" {
  type = string
}

variable "internal" {
  type = bool
}

variable "subnets_id" {
  type = list()
}

variable "listener_port" {
  type = number
}

variable "listener_protocol" {
  type = string
}

variable "action_type" {
  type = string
}
