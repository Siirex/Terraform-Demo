
resource "aws_security_group" "sg-centos-terraform" {

  vpc_id = aws_vpc.terraform-vpc.id

  ingress {
    description = "allow ssh to centos"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow request http to centos"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_security_group" "sg-rds-mysql-terraform" {

  vpc_id = aws_vpc.terraform-vpc.id
  
  ingress {
    description = "allow request from ec2-centos (public-subnet) to rds"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.terraform-public-subnet}"] //CIDR public subnet
  }

  egress {
    description = "allow connecting in this VPC"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.terraform-vpc-test}"] //CIDR VPC
  }

  tags = {
    Name = "sg-rds-mysql-terraform-${var.owner}"
  }
}
