
variable "sg_source_ingress" {
  type = list
}

variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "role" {
  type = string
}

variable "artifact" {
  type = string
}

variable "compute_type" {
  type = string
}

variable "image" {
  type = string
}

variable "type" {
  type = string
}

variable "privileged_mode" {
  type = bool
}

variable "image_pull_credentials" {
  type = string
}

/*
variable "env_vars" {
  type = list(object({
    name = string
    value = string
  }))
}
*/

variable "log_group_name" {
  type = string
}

variable "log_stream_name" {
  type = string
}

variable "source_type" {
  type = string
}

variable "source_location" {
  type = string
}

variable "buildspec_file" {
  
}

