
# Use Class Load Balancer (CLB)

resource "aws_elb" "elb" {
  name = "terraform-asg-${var.owner}"

  # availability_zones = [ "${var.terraform-az-1a}", "${var.terraform-az-1b}" ]
  subnets = [ aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id ]

  security_groups = [ aws_security_group.sg_elb.id ]

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  health_check {
    target = "TCP:${var.server_port}"
    # target = "HTTP:${var.server_port}/path"
    interval = 30
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  listener {
    lb_port = var.elb_port
    lb_protocol = "http"

    instance_port = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_security_group" "sg_elb" {
  name = "terraform-sg-elb-${var.owner}"
  vpc_id = aws_vpc.terraform-vpc.id

  egress {
    from_port = var.elb_port
    to_port = var.elb_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = var.elb_port
    to_port = var.elb_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
