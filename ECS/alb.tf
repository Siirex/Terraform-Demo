
resource "aws_lb" "alb" {
  name = "terraform-alb"
  load_balancer_type = "application"
  internal = false

  security_groups = [ aws_security_group.alb.id ]
  subnets = aws_subnet.public.*.id
  # subnets = [ aws_subnet.public__a.id, aws_subnet.public__b.id ]
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn

  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb.id
    type = "forward"
  }
}

resource "aws_lb_target_group" "alb" {
  name = "terraform-target-group"
  vpc_id = aws_vpc.vpc.id

  port = 80
  protocol = "HTTP"
  target_type = "instance"

  health_check {
    port = 80
    path = "/"
  }
}
