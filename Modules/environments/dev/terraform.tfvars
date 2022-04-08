
terraform-iam-access-key = ""
terraform-iam-secret-key = ""
terraform-region = "ap-southeast-1"

environment = "development"

# VPC
cidr = "10.1.0.0/16"
azs-public-subnet = {
  "ap-southeast-1a" = 1
  "ap-southeast-1b" = 2
}
azs-private-subnet = {
  "ap-southeast-1a" = 3
  "ap-southeast-1b" = 4
}
nat-gateway = false //use nat_instance

# Webserver cluster
ami-webserver = "ami-0356b1cd4aa0ee970"
type-webserver = "t2.micro"
min-webserver = 1
max-webserver = 1
port-alb-access = 80
protocol-alb-access = "HTTP"
path-alb-healthcheck = "/menu.php"
port-alb-health = 80
protocol-alb-health = "HTTP"
action-alb-request = "forward"

# Bastion / Nat Instance
ami-natinstance = "ami-6aa38238"
type-natinstance = "t2.micro"
min-natinstance = 1
max-natinstance = 1

# Database
db-engine = "mysql"
db-engine-version = "5.7"
db-instance-type = "db.t2.micro"
db-name = "hoangminh"
db-username = "siirex"
db-password = "xxxxxxxxxx"
db-port = 3306
db-public-access = true


