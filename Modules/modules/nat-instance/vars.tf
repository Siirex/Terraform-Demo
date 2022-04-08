
variable "env" {
  type = string
}

variable "vpc-id" {
  type = string
}

variable "subnet-id" {
  type = string
}

variable "az" {
  type = string
}

variable "ami" {
  type = string
}

variable "type" {
  type = string
}

variable "key" {}
variable "userdata" {}

variable "min" {
  type = number
}

variable "max" {
  type = number
}

variable "instance-profile" {
  type = string
}
