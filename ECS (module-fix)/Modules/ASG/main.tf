
# AMI for Instance of ECS Cluster
data "aws_ami" "container_instance" {
  filter {
    name = "name"
    values = ["${var.ami_ecs_instance}"]
  }

  most_recent = true
  owners = ["amazon"]
}

resource "aws_security_group" "container_instance" {
  name = "terraform-sg-container-instancer"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "container_instance" {
  name_prefix = var.name_prefix_launch_configuration

  image_id = data.aws_ami.container_instance.id
  instance_type = var.container_instance_type
  key_name = var.public_key_name
  user_data = var.container_user_data
  security_groups = [ aws_security_group.container_instance.id ]

  associate_public_ip_address = var.associate_public_ip

  # IAM Role 'ecs_container_instance'
  iam_instance_profile = var.iam_profile

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "container_instance" {
  name = var.name_asg

  launch_configuration = aws_launch_configuration.container_instance.id
  desired_capacity = var.desired_capacity
  min_size = var.min_container
  max_size = var.min_container

  health_check_type = var.healthcheck_type

  # Container đặt tại Public Subnets
  vpc_zone_identifier = var.subnets_id

  force_delete = true

  depends_on = [ aws_launch_configuration.container_instance ]
}






