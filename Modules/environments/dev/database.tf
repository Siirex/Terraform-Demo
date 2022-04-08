
module "database" {
  source = "../../modules/database"

  env = var.environment
  vpc-id = "${module.vpc.vpc_id}"
  public = var.db-public-access

  engine = var.db-engine
  engine-version = var.db-engine-version
  type = var.db-instance-type

  db-name = var.db-name
  username = var.db-username
  password = var.db-password
  port = var.db-port

  az = "${module.vpc.az[0]}"
  subnet-group = "${module.vpc.db_subnet_group}"
}

# Allow MySQL traffics form Webserver:
resource "aws_security_group_rule" "sg-ingress-rds" {
  security_group_id = "${module.database.sg_rds_id}"
  type = "ingress"

  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = "${module.webserver-cluster.sg_asg_id}"
}


