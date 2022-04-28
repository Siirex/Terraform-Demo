
variable "environment" {
  type = string
  default = "staging"
}

variable "application" {
  type = string
  default = "MONSTLAB"
}

variable "container_definitions_message" {
  type = string
  default = "S I I R E X - s t a g i n g"
}

variable "region" {
  default = "ap-southeast-1"
}

variable "acc_id" {
  default = "569377550849"
}

variable "tag_image" {
  default = "v1.0"
}

variable "repo_image" {
  default = "terraform"
}






