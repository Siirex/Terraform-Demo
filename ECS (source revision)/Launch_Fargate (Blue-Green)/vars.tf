
variable "environment" {
  type = string
  default = "staging"
}

variable "application" {
  type = string
  default = "MONSTLAB"
}

# --------------------------------------------

variable "vpc_cidr" {
  type = string
  default = "10.1.0.0/16"
}

variable "public_cidrs" {
  type = list
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_cidrs" {
  type = list
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "enable_nat_gateway" {
  default = true
}

variable "nat_gateway_on_1_AZ" {
  default = true
}

# --------------------------------------------

variable "container_definitions_message" {
  type = string
  default = "S I I R E X - s t a g i n g"
}

# --------------------------------------------

variable "tag_image" {
  default = "latest"
}

variable "repo_image" {
  default = "terraform"
}
