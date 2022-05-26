
variable "use_pipline" {
  type = bool
}

# --------------------------------

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
  default = ""
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
  type = list
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

# -------------------------------

variable "name_green_target_group" {
  type = string
  default = ""
}

variable "green_target_port" {
  type = number
  default = 80
}

variable "green_target_protocol" {
  type = string
  default = ""
}

# -------------------------------

variable "green_listener_port" {
  type = number
  default = 9090
}

variable "green_listener_protocol" {
  type = string
  default = ""
}
