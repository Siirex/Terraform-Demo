
# Target Group for ALB:
resource "aws_alb_target_group" "alb-target-group" {
  name = "terraform-alb-target-group"
  vpc_id = aws_vpc.terraform-vpc.id

  target_type = "instance"
  port = 80
  protocol = "HTTP"

  health_check {
    path = "/healthcheck" //destination cho protocol của request health_check
    protocol = "HTTP"
    port = 80

    interval = 10
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

# Register instances (ASG) with Target_Group:
resource "aws_autoscaling_attachment" "targets-asg" {
  alb_target_group_arn = aws_alb_target_group.alb-target-group.arn
  autoscaling_group_name = aws_autoscaling_group.asg.id
}

/*
resource "aws_alb_target_group_attachment" "targets-instance-weberver-1" {
  target_group_arn = aws_alb_target_group.alb-target-group.arn
  target_id = aws_instance.webserver.id
  port = 80 //port mà các Target (Instances) nhận được lưu lượng truy cập
}
*/

# Application Load Balancer:
resource "aws_alb" "alb" {
  name = "terraform-alb-${var.owner}"

  internal = false //public IP connection
  security_groups = [ aws_security_group.sg-alb.id ]
  subnets = [ aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id ]
  ip_address_type = "ipv4"

  load_balancer_type = "application"

  idle_timeout = 60
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  enable_http2 = false

  # Đảm bảo Bucket Policy phải được tạo trước khi bật ALB logging
  depends_on = [ aws_s3_bucket_policy.log-bucket-policy ]

  access_logs {
    bucket = "${var.bucket-alb-log}" //aws_s3_bucket.alb_access_logs.bucket
    prefix = "${var.prefix-bucket-alb-log}"
    enabled = true //default
  }
}

# Load Balancer Listener:
resource "aws_alb_listener" "alb-listener-http" {
  load_balancer_arn = aws_alb.alb.arn

  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn

    /*type = "redirect" //áp dụng cho việc chuyển hướng từ HTTP(80) sang HTTPS(443)
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }*/
  }
}

/*
resource "aws_alb_listener" "alb-listener-https" {
  load_balancer_arn = aws_alb.alb.arn

  port = 443
  protocol = "HTTPS"
  ssl_policy = "ALBSecurityPolicy-2022-03"
  certificate_arn = var.acm_cert_arn

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }
}
*/

# Access Control for ALB:
resource "aws_security_group" "sg-alb" {
  name = "terraform-sg-alb-${var.owner}"
  vpc_id = aws_vpc.terraform-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

