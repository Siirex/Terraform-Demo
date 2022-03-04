
resource "aws_security_group" "sg-centos-terraform" {

  vpc_id = aws_vpc.terraform-vpc.id

  /*
  ingress {
    description = "allow ssh to Cluster"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */

  egress {
    description = "allow all outbound connections"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-centos-terraform-${var.owner}"
  }
}

resource "aws_security_group_rule" "sg-ingress-centos-terraform" {
  type = "ingress"
  description = "allow request http form ELB to Cluster"
  security_group_id = aws_security_group.sg-centos-terraform.id

  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg_elb.id
}

/*
resource "aws_security_group" "sg-rds-mysql-terraform" {

  vpc_id = aws_vpc.terraform-vpc.id
  
  ingress {
    description = "allow request from ec2-centos (public-subnet) to rds"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [ "${var.terraform-public-subnet-1a}", "${var.terraform-public-subnet-1b}" ] //CIDR public subnet
  }

  egress {
    description = "allow connecting only on this VPC"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.terraform-vpc-test}"] //CIDR VPC
  }

  tags = {
    Name = "sg-rds-mysql-terraform-${var.owner}"
  }
}
*/