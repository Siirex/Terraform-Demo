
variable "vpc_id" {
  type = string
}

variable "ami_ecs_instance" {
  type = string
}

variable "name_prefix_launch_configuration" {
  type = string
}

variable "container_instance_type" {
  type = string
}

variable "public_key_name" {
}

variable "container_user_data" {
}

variable "associate_public_ip" {
  type = bool
}

variable "iam_profile" {
  type = string
}

# ----------------------------------------

variable "name_asg" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "min_container" {
  type = number
}

variable "max_container" {
  type = number
}

variable "healthcheck_type" {
  type = string
}

variable "subnets_id" {
  type = list()
}




