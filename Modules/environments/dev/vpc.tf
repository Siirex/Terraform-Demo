
module "vpc" {
  source = "../../modules/vpc"

  env = var.environment
  cidr-vpc = var.cidr
  dns-hostname = true
  
  public-subnet-number = var.azs-public-subnet
  private-subnet-number = var.azs-private-subnet

  enable-nat-gateway = var.nat-gateway

  interface-network = "${module.nat-instance.interface-network}"
}
