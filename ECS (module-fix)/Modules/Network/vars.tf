
variable "env" {
  type = string
}

variable "app" {
  type = string
}

# ---------------------------

variable "vpc_cidr" {
  type = string
}

variable "public_cidr" {
  type = list()
}

variable "private_cidr" {
  type = list()
}

variable "azs" {
  type = list()
}

# ---------------------------

variable "enable_nat_gateway" {
  type = bool
}

variable "create_1_nat_gateway_on_1_AZ" {
  type = bool
}

