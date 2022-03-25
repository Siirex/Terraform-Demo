
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
  default = 3
}

variable "bucket-alb-log" {
  default = "terraform-alb-access-logs"
}
variable "prefix-bucket-alb-log" {
  default = "log-siirex"
}

variable "bucket-upload" { default = "terraform-upload-files-form-asg" }
variable "object-upload" { default = "terraform-upload-files" }

variable "aws-account-id" {
  default = "527947726964"
}

