
# Public Key for Instance of Cluster
resource "aws_key_pair" "key" {
  key_name = "terraform-key"
  public_key = "${file("key-access-instances.pub")}"
}

# AMI for Instance of ECS Cluster
data "aws_ami" "instance" {
  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }

  most_recent = true
  owners = ["amazon"]
}

resource "aws_launch_configuration" "instance" {
  name_prefix = "terraform-launch-"

  image_id = data.aws_ami.instance.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.key.key_name
  user_data = "${file("provision.sh")}"
  security_groups = [ aws_security_group.ecs_cluster.id ]

  associate_public_ip_address = true

  # IAM Role 'ecs_container_instance'
  iam_instance_profile = aws_iam_instance_profile.ecs_container_instance.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "instance" {
  name = "terraform-instances"

  launch_configuration = aws_launch_configuration.instance.id
  desired_capacity = 1
  min_size = 1
  max_size = 1

  health_check_type = "EC2"

  # ECS Cluster đặt tại Public Subnets
  vpc_zone_identifier = aws_subnet.public.*.id
  # vpc_zone_identifier = [ aws_subnet.public__a.id, aws_subnet.public__b.id ]

  force_delete = true

  depends_on = [ aws_launch_configuration.instance ]

  tag {
    key = "Name"
    value = "terraform-instances"
    propagate_at_launch = true
  }
}
