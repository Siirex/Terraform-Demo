
variable "terraform-iam-access-key" {}
variable "terraform-iam-secret-key" {}
variable "terraform-region" {}
variable "terraform-az-1a" {}
variable "terraform-az-1b" {}

variable "terraform-instance-type" {}
# variable "terraform-centos-key" {}
variable "terraform-centos-ami" {}

variable "terraform-vpc-test" {}
variable "terraform-public-subnet-1a" {}
variable "terraform-public-subnet-1b" {}
variable "terraform-private-subnet-1a" {}
variable "terraform-private-subnet-1b" {}

variable "owner" {
  description = "owner name of project"
  type = string
  default = "siirex"
}

variable "asg-min-instance" {
  type = number
  default = 2
}

variable "asg-max-instance" {
  type = number
  default = 4
}

variable "server_port" {
  type = number
  default = 8080
}

variable "elb_port" {
  type = number
  default = 80
}
