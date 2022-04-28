
resource "aws_security_group" "alb" {
  name = "terraform-sg-alb"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
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

resource "aws_lb_target_group" "alb" {
  name = var.name_target_group
  vpc_id = var.vpc_id

  port = var.targetgroup_port
  protocol = var.targetgroup_protocol
  target_type = var.targetgroup_type

  /*
  health_check {
    port = 80
    path = "/"
  }
  */
}

resource "aws_autoscaling_attachment" "targets-asg" {
  count = var.fargate ? 0 : 1
  alb_target_group_arn = aws_lb_target_group.alb.arn
  autoscaling_group_name = var.asg_id
}

resource "aws_lb" "alb" {
  name = var.name_alb
  load_balancer_type = var.lb_type
  internal = var.internal

  security_groups = [ aws_security_group.alb.id ]
  subnets = var.subnets_id
  }

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn

  port = var.listener_port
  protocol = var.listener_protocol

  default_action {
    target_group_arn = aws_lb_target_group.alb.id
    type = var.action_type
  }
}







