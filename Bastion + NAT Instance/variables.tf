
variable "owner" {
  type = string
}

variable "access-key" {
  type = string
}

variable "secret-key" {
  type = string
}

variable "region" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "cidr-vpc" {
  type = string
}

variable "cidr-public-subnet" {
  type = list(string)
}

variable "cidr-private-subnet" {
  type = list(string)
}

variable "ami-webserver" {
  type = string
}

variable "ami-nat-instance-bastion" {
  type = string
}

variable "instance-type" {
  type = string
}

variable "db-name" {
  type = string
}

variable "db-username" {
  type = string
}

variable "db-pass" {
  type = string
}


