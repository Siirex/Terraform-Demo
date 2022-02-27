
resource "aws_elb" "elb" {
  name = "terraform-asg-${var.owner}"

  # availability_zones = [ "${var.terraform-az-1a}", "${var.terraform-az-1b}" ] //xung đột với "subnets"
  # subnets = [ aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id ] //error: ELB cannot be attached to multiple subnets in the same AZ
  subnets = [ aws_subnet.public-subnet-1a.id ]

  security_groups = [ aws_security_group.sg_elb.id ]

  health_check {
    target = "HTTP:${var.server_port}/"
    interval = 30
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  listener {
    # ELB use port 80 to listen for HTTP requests
    lb_port = var.elb_port
    lb_protocol = "http"

    # Instances use port 8080 to listen for HTTP requests
    instance_port = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_security_group" "sg_elb" {
  name = "terraform-sg-elb-${var.owner}"
  vpc_id = aws_vpc.terraform-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.elb_port
    to_port = var.elb_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


