
/*
data "template_file" "provision" {
  template = file("${path.module}/files/provision.sh")
}
*/

resource "aws_launch_configuration" "asg-webserver" {
  name = "terraform-asg-webserver-config-${var.owner}"

  image_id = var.ami-webserver
  instance_type = var.instance-type
  key_name = aws_key_pair.public-key.key_name
  security_groups = [ aws_security_group.sg-instance.id ]
  # user_data = "${data.template_file.provision.rendered}"
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

  # Vì đặt ở Private Subnet, nên khong liên kết cho nó Public IP
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-webserver" {
  name = "terraform-asg-webserver-${var.owner}"
  
  vpc_zone_identifier = [ aws_subnet.private-subnet[0].id, aws_subnet.private-subnet[1].id ]

  min_size = 1
  max_size = 1

  launch_configuration = aws_launch_configuration.asg-webserver.id

  force_delete = true

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "terraform-asg-webserver-${var.owner}"
    propagate_at_launch = true
  }
}
