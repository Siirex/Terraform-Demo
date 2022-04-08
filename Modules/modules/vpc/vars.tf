
variable "env" {
  type = string
}

# ----------------------------------

variable "cidr-vpc" {
  type = string
}

variable "dns-support" {
  default = true
}

variable "dns-hostname" {
  type = bool
}

# ----------------------------------

variable "public-subnet-number" {
  type = map(number)
}
variable "private-subnet-number" {
  type = map(number)
}

/*
variable "public-subnet-number" {
  type = map(number)

  default = {
    "ap-southeast-1a" = 1
    "ap-southeast-1b" = 2
  }
}

variable "private-subnet-number" {
  type = map(number)

  default = {
    "ap-southeast-1a" = 3
    "ap-southeast-1b" = 4
  }
}
*/

# ----------------------------------

variable "enable-nat-gateway" {
  description = "if false, nat_gateway disable, nat_instance will use"
  type = bool
}

variable "interface-network" {
  type = string
}




