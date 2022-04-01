
resource "aws_alb_target_group" "target-group" {
  name = "terraform-target-group-${var.owner}"
  vpc_id = aws_vpc.vpc.id

  target_type = "instance"
  port = 80
  protocol = "HTTP"

  health_check {
    path = "/menu.php"
    protocol = "HTTP"
    port = 80
  }

  tags = {
    Name = "terraform-target-group-${var.owner}"
  }
}

resource "aws_autoscaling_attachment" "attach-asg-webserver" {
  alb_target_group_arn = aws_alb_target_group.target-group.arn
  autoscaling_group_name = aws_autoscaling_group.asg-webserver.id
}

resource "aws_alb" "alb" {
  name = "terraform-alb-${var.owner}"

  internal = false
  security_groups = [ aws_security_group.sg-alb.id ]
  subnets = [ aws_subnet.public-subnet[0].id, aws_subnet.public-subnet[1].id ]
  ip_address_type = "ipv4"

  load_balancer_type = "application"

  idle_timeout = 60
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  enable_http2 = false

  depends_on = [ aws_autoscaling_group.asg-webserver ]

  tags = {
    Name = "terraform-alb-${var.owner}"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb.arn

  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.target-group.arn
  }
}


