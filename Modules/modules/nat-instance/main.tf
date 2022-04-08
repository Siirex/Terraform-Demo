
resource "aws_network_interface" "nat-instance" {
  subnet_id = var.subnet-id
  security_groups = [ aws_security_group.sg-nat-instance.id ]

  source_dest_check = false
}

resource "aws_eip" "eip" {
  vpc = true
  network_interface = aws_network_interface.nat-instance.id
}

# NAT Instance -------------------------------------------------------

resource "aws_launch_template" "nat-instance" {
  name = "terraform-nat-instance-${var.env}"

  image_id = var.ami
  instance_type = var.type
  key_name = var.key
  user_data = var.userdata

  placement {
    availability_zone = var.az
  }

  network_interfaces {
    delete_on_termination = false
    network_interface_id = aws_network_interface.nat-instance.id
  }

  iam_instance_profile {
    arn = var.instance-profile
  }
}

resource "aws_autoscaling_group" "nat-instance" {
  name = "terraform-nat-instance-${var.env}"
  force_delete = true

  availability_zones = [ var.az ]

  max_size = var.max
  min_size = var.min

  launch_template {
    id = aws_launch_template.nat-instance.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "terraform-nat-instance-${var.env}"
    propagate_at_launch = true
  }
}

# SG for NAT Instance ----------------------------------------------

resource "aws_security_group" "sg-nat-instance" {
  name = "terraform-sg-nat-instance-${var.env}"
  vpc_id = var.vpc-id
}

/*
locals {
  sg-nat-instance-rules = {
    "rule_1" = ["ingress", 22, 22, "tcp", ["0.0.0.0/0"]] //Allow SSH connection input
    "rule_2" = ["egress", 0, 0, "-1", ["0.0.0.0/0"]] // Cho phép SSH, HTTP traffic, ... đi ra đến bất cứ nguồn nào
  }
}

resource "aws_security_group_rule" "sg-nat-instance-rules-a" {
  security_group_id = aws_security_group.sg-nat-instance.id

  for_each = local.sg-nat-instance-rules

  type = each.value[0]
  from_port = each.value[1]
  to_port = each.value[2]
  protocol = each.value[3]
  cidr_blocks = each.value[4]
}
*/
