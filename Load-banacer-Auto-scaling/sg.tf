
resource "aws_security_group" "sg-centos-terraform" {

  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "sg-centos-terraform-${var.owner}"
  }
}

# Inbound rule: Allow HTTP request for Cluster
resource "aws_security_group_rule" "sg-http-ingress-centos-terraform" {
  type = "ingress"
  description = "allow HTTP traffic form LB to Cluster"
  security_group_id = aws_security_group.sg-centos-terraform.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg_elb.id
}

# Inbound rule: Allow SSH connection for Cluster
resource "aws_security_group_rule" "sg-ssh-ingress-centos-terraform" {
  type = "ingress"
  description = "allow SSH traffic form LB to Cluster"
  security_group_id = aws_security_group.sg-centos-terraform.id

  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg_elb.id
}

# Outbound rule: Allow Cluster communicate with Internet
resource "aws_security_group_rule" "sg-http-egress-centos-terraform" {
  type = "egress"
  security_group_id = aws_security_group.sg-centos-terraform.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg_elb.id //source output is LB
}

# Outbound rule: Allow Cluster send MySQL/Aurora traffics on 2 Private Subnet
resource "aws_security_group_rule" "sg-http-egress-centos-terraform" {
  type = "egress"
  security_group_id = aws_security_group.sg-centos-terraform.id

  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = [ "${aws_subnet.private-subnet-1a}", "${aws_subnet.private-subnet-1b}" ]
}

# ------------------------------------------------------------------------------------------------

resource "aws_security_group" "sg-rds-mysql-terraform" {

  vpc_id = aws_vpc.terraform-vpc.id
  
  ingress {
    description = "allow request from ec2-centos (public-subnet) to rds"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [ "${var.terraform-public-subnet-1a}", "${var.terraform-public-subnet-1b}" ]
  }

  egress {
    description = "allow connecting only on this VPC"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.terraform-vpc-test}"]
  }

  tags = {
    Name = "sg-rds-mysql-terraform-${var.owner}"
  }
}