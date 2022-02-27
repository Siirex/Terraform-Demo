
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "terraform-centos-key" {
  key_name = "terraform-centos-key"
  public_key = tls_private_key.tls_key.public_key_openssh
  # public_key = var.terraform-centos-key
  # public_key = "${file(key.pub)}"
}

/*
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name = "terraform-centos-key"
  public_key = tls_private_key.tls_key.public_key_openssh
}
*/

resource "aws_instance" "ec2-centos-terraform" {
  ami = var.terraform-centos-ami
  instance_type = var.terraform-instance-type
  key_name = "${aws_key_pair.terraform-centos-key.key_name}"

  # user_data = "${file(setup-webserver.sh)}"
  user_data = <<EOF
    #!/bin/bash -ex
    yum -y update
    yum -y install httpd php mysql php-mysql
    chkconfig httpd on
    service httpd start
    cd /var/www/html
    wget https://s3-us-west-2.amazonaws.com/us-west-2-aws-training/awsu-spl/spl-13/scripts/app.tgz
    tar xvfz app.tgz
    chown apache:root /var/www/html/rds.conf.php
  EOF
  
  # security_groups = ["${aws_security_group.allow_ssh.name}"]
  vpc_security_group_ids = ["${aws_security_group.sg-centos-terraform.id}"]
  subnet_id = aws_subnet.public-subnet.id
  
  tags = {
    Name = "ec2-centos-terraform-${var.owner}"
  }
}
