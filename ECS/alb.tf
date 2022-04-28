
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

# Register ASG Instances with Target_Group:
resource "aws_autoscaling_attachment" "targets-asg" {
  alb_target_group_arn = aws_lb_target_group.alb.arn
  autoscaling_group_name = aws_autoscaling_group.instance.id
}

resource "aws_lb" "alb" {
  name = "terraform-alb"
  load_balancer_type = "application"
  internal = false

  security_groups = [ aws_security_group.alb.id ]
  subnets = aws_subnet.public.*.id
  
  depends_on = [ aws_autoscaling_group.instance ]
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
