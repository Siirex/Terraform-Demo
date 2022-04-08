
variable "env" {
  type = string
}

variable "vpc-id" {
  type = string
}

variable "private-subnets" {
  type = list(string)
}

# ---------------------------------------

variable "ami-instance" {
  type = string
}

variable "type-instance" {
  type = string
}

variable "key-name" {}

variable "user-data" {}

variable "associate-public-ip" {
  type = bool
}

variable "min-instances" {
  type = number
}

variable "max-instances" {
  type = number
}

# --------------------------------------

variable "custom-tags" {
  type = map(string)
  default = {
    "key" = "value"
  }
}

# -------------------------------------

variable "alb-request-access-protocol" {
  type = string
}

variable "alb-request-access-port" {
  type = number
}

variable "alb-request-health-protocol" {
  type = string
}

variable "alb-request-health-port" {
  type = number
}

variable "alb-request-health-path" {
  type = string
}

variable "alb-internal" {
  type = bool
}

variable "alb-listener-https" {
  description = "if false, alb will listening HTTP(80)"
  type = bool
}

variable "alb-listener-protocol" {
  type = string
}

variable "alb-listener-port" {
  type = number
}

variable "alb-action" {
  type = string
}


