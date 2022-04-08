
module "iam" {
  # count = var.nat-gateway ? 0 : 1 //false
  source = "../../modules/global/IAM"

  env = var.environment
  Allow-ModifyInstanceAttribute = "Allow"
}

# -------------------------------------------------------------

data "template_file" "userdata-nat-instance" {
  template = file("${path.root}/files/nat-instance.sh")
  vars = {
    region = var.terraform-region
  }
}

module "nat-instance" {
  # count = var.nat-gateway ? 0 : 1 //false
  source = "../../modules/nat-instance"

  env = var.environment
  vpc-id = "${module.vpc.vpc_id}"
  subnet-id = "${module.vpc.public_subnets[0]}" // ???
  az = "${module.vpc.az[0]}" // ??

  ami = var.ami-natinstance
  type = var.type-natinstance
  key = "${aws_key_pair.public-key.key_name}"
  userdata = "${base64encode(data.template_file.userdata-nat-instance.rendered)}"

  min = var.min-natinstance
  max = var.max-natinstance

  instance-profile = "${module.iam.instance-profile}"
}

//Allow SSH connection input
resource "aws_security_group_rule" "sg-nat-instance-rules-1" {
  # count = var.nat-gateway ? 0 : 1 //false
  security_group_id = module.nat-instance.sg-nat-instance-id
  type = "ingress"

  to_port = 22
  from_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

// Cho phép SSH, HTTP traffic, ... đi ra đến bất cứ nguồn nào
resource "aws_security_group_rule" "sg-nat-instance-rules-2" {
  # count = var.nat-gateway ? 0 : 1 //false
  security_group_id = module.nat-instance.sg-nat-instance-id
  type = "egress"

  to_port = 0
  from_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
}

// Allow SSH to Wenserver cluster
resource "aws_security_group_rule" "sg-nat-instance-rules-3" {
  # count = var.nat-gateway ? 0 : 1 //false
  security_group_id = module.nat-instance.sg-nat-instance-id
  type = "egress"

  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.webserver-cluster.sg_asg_id
}

// Allow Webserver Cluster update packages --> Run App
resource "aws_security_group_rule" "sg-nat-instance-rules-4" {
  # count = var.nat-gateway ? 0 : 1 //false
  security_group_id = module.nat-instance.sg-nat-instance-id
  type = "ingress"

  from_port = 0
  to_port = 65535
  protocol = "-1"
  source_security_group_id = module.webserver-cluster.sg_asg_id
}



