
variable "container_definitions_message" {
  default = "SIIREX"
}

variable "acc_id" {
  default = "569377550849"
}

variable "regionn" {
  default = "ap-southeast-1"
}

variable "tag_image" {
  default = "v1.0"
}

variable "repo_image" {
  default = "terraform"
}


variable "azs" {
  type = list
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnets" {
  type = list
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnets" {
  type = list
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}

