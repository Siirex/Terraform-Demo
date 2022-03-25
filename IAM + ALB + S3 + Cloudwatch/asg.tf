/*
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}
*/

resource "aws_key_pair" "terraform-centos-key" {
  key_name = "terraform-centos-key"
  # public_key = tls_private_key.tls_key.public_key_openssh
  # public_key = var.terraform-centos-key
  public_key = "${file("key-access-instances.pub")}"
}

data "template_file" "provision" {
  template = "${file("${path.module}/provision.sh")}"
  vars = {
    bucket = "${var.bucket-upload}"
    object = "${var.object-upload}"
  }
}

resource "aws_launch_configuration" "launch_instance_config" {
  
  name = "terraform-launch-instance-config-${var.owner}"
  image_id = var.terraform-centos-ami
  instance_type = var.terraform-instance-type
  key_name = "${aws_key_pair.terraform-centos-key.key_name}"
  security_groups = ["${aws_security_group.sg-centos-terraform.id}"]
  associate_public_ip_address = true

  # Attach with IAM Role to ASG:
  iam_instance_profile = aws_iam_instance_profile.profile.id

  # user_data = "${file(setup-webserver.sh)}"
  user_data = "${data.template_file.provision.rendered}"
  
  depends_on = [ aws_iam_policy.iam-policy, aws_iam_role.iam-role, aws_s3_bucket.upload, aws_s3_bucket_object.object-bucket-upload ]
  
  lifecycle {
      create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg" {
  name = "terraform-asg-${var.owner}"
  launch_configuration = aws_launch_configuration.launch_instance_config.id

  vpc_zone_identifier = [ aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id ]

  min_size = var.asg-min-instance
  max_size = var.asg-max-instance

  # Enable quan ly metrics
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  force_delete = true

  tag {
    key = "Name"
    value = "terraform-asg-${var.owner}"
    propagate_at_launch = true
  }
}
