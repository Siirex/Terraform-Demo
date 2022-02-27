
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "terraform-centos-key" {
  key_name = "terraform-centos-key"
  public_key = tls_private_key.tls_key.public_key_openssh
  # public_key = var.terraform-centos-key
  # public_key = "${file(key.pub)}"
}

resource "aws_launch_configuration" "launch_instance_config" {
  
  name = "terraform-launch-instance-config-${var.owner}"
  image_id = var.terraform-centos-ami
  instance_type = var.terraform-instance-type

  key_name = "${aws_key_pair.terraform-centos-key.key_name}"

  security_groups = ["${aws_security_group.sg-centos-terraform.id}"]

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
  
  lifecycle {
      create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg" {
  
  launch_configuration = aws_launch_configuration.launch_instance_config.id

  vpc_zone_identifier = [ aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id ] //Webserver Cluster inside Public Subnet 1a & 1b (đảm bảo tính sẵn sàng)
  # availability_zones = [ "${var.terraform-az-1a}", "${var.terraform-az-1b}" ] //xung đột với "vpc_zone_identifier", vì bản thân thằng này chỉ định Public Subnet, trong Subnet đó đã chỉ định AZ luôn rồi (az-1a & az-1b)

  min_size = var.asg-min-instance
  max_size = var.asg-max-instance

  load_balancers = [aws_elb.elb.name]
  health_check_type = "ELB"  

  tag {
    key = "Name"
    value = "terraform-asg-${var.owner}"
    propagate_at_launch = true
  }
}

