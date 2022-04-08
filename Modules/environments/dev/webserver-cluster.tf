
data "template_file" "provision" {
  template = file("${path.module}/files/provision.sh")
}

module "webserver-cluster" {
  source = "../../modules/webserver-cluster"

  env = var.environment
  vpc-id = "${module.vpc.vpc_id}"
  private-subnets = module.vpc.private_subnets // ???

  ami-instance = var.ami-webserver
  type-instance = var.type-webserver
  key-name = "${aws_key_pair.public-key.key_name}"
  user-data = "${data.template_file.provision.rendered}"

  # Vì đặt ở Private Subnet, nên khong liên kết cho nó Public IP
  associate-public-ip = false

  min-instances = var.min-webserver
  max-instances = var.max-webserver

  alb-request-access-port = var.port-alb-access
  alb-request-access-protocol = var.protocol-alb-access
  alb-request-health-path = var.path-alb-healthcheck
  alb-request-health-port = var.port-alb-health
  alb-request-health-protocol = var.protocol-alb-health

  alb-internal = false

  # Enable HTTPS Listener?
  alb-listener-https = false //listening HTTP(80)
  alb-listener-protocol = var.protocol-alb-access
  alb-listener-port = var.port-alb-access
  alb-action = var.action-alb-request
}



# Allow SSH conncetion form Bastion host:
resource "aws_security_group_rule" "sg-asg-ingress-ssh" {
  security_group_id = module.webserver-cluster.sg_asg_id

  type = "ingress"

  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${module.nat-instance.sg-nat-instance-id}"
}

# Allow 'ping' traffics to hosts in VPC:
resource "aws_security_group_rule" "sg-asg-egress-icmp" {
  security_group_id = module.webserver-cluster.sg_asg_id

  type = "egress"

  from_port = -1
  to_port = -1
  protocol = "icmp"
  cidr_blocks = ["${module.vpc.vpc_cidr}"]
}

# Allow access Internet through NAT Instance
resource "aws_security_group_rule" "sg-asg-egress-setup-app" {
  security_group_id = module.webserver-cluster.sg_asg_id

  type = "egress"

  from_port = 0
  to_port = 65535
  protocol = "-1"
  source_security_group_id = module.nat-instance.sg-nat-instance-id
}

/*
# Allow Mysql traffic to RDS
resource "aws_security_group_rule" "sg-asg-egress-setup-app" {
  security_group_id = module.webserver-cluster.sg_asg_id

  type = "egress"

  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = module.database.sg_rds_id
}
*/
