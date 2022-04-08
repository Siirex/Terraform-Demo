
variable "terraform-iam-access-key" {}
variable "terraform-iam-secret-key" {}
variable "terraform-region" {}

variable "environment" {}

# VPC
variable "cidr" {}
variable "azs-public-subnet" { type = map(number) }
variable "azs-private-subnet" { type = map(number) }
variable "nat-gateway" { type = bool }


# Webserver cluster
variable "ami-webserver" {}
variable "type-webserver" {}

variable "min-webserver" {}
variable "max-webserver" {}

variable "port-alb-access" {}
variable "protocol-alb-access" {}

variable "path-alb-healthcheck" {}
variable "port-alb-health" {}
variable "protocol-alb-health" {}
variable "action-alb-request" {}


# Bastion / Nat Instance
variable "ami-natinstance" {}
variable "type-natinstance" {}

variable "min-natinstance" {}
variable "max-natinstance" {}

# Database
variable "db-engine" {}
variable "db-engine-version" {}
variable "db-instance-type" {}
variable "db-name" {}
variable "db-username" {}
variable "db-password" {}
variable "db-port" {}
variable "db-public-access" { type = bool }









