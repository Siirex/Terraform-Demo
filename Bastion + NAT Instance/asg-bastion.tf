
resource "aws_network_interface" "nat-instance-interface" {
  subnet_id = aws_subnet.public-subnet[0].id
  security_groups = [ aws_security_group.sg-bastion.id ]

  source_dest_check = false
}

# Như đã nói, để có Network Interface cố định sau khi NAT_instance bị ASG launch mới
# Cần gán EIP (Public IP cố định) cho Network Interface
resource "aws_eip" "eip-nat-instance" {
  vpc = true
  network_interface = aws_network_interface.nat-instance-interface.id
}

data "template_file" "userdata-nat-instance" {
  template = file("${path.root}/files/nat-instance.sh")
  vars = {
    region = var.region
  }
}

resource "aws_launch_template" "asg-bastion-config" {
  name = "terraform-asg-bastion-config-${var.owner}"

  image_id = var.ami-nat-instance-bastion
  instance_type = var.instance-type
  key_name = aws_key_pair.public-key.key_name
  user_data = base64encode(data.template_file.userdata-nat-instance.rendered) //sử dụng script để tắt thuộc tính kiểm tra nguồn/đích "SrcDestCheck" cho NAT Instance

  placement {
    availability_zone = var.azs[0]
  }

  network_interfaces {
    delete_on_termination = false //interface có bị hủy khi chấm dứt Instance hay không?
    network_interface_id = aws_network_interface.nat-instance-interface.id
  }

  # Cung cấp IAM Permission để NAT_instance tự thay đổi thuộc tính bắt buộc "SrcDestCheck"
  iam_instance_profile {
    arn = aws_iam_instance_profile.nat-instance-profile.arn
  }
}

resource "aws_autoscaling_group" "asg-bastion" {
  name = "terraform-asg-bastion-${var.owner}"
  force_delete = true
  availability_zones = [ var.azs[0] ]

  min_size = 1
  max_size = 1

  launch_template {
    id = aws_launch_template.asg-bastion-config.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "terraform-asg-bastion-${var.owner}"
    propagate_at_launch = true
  }
}
