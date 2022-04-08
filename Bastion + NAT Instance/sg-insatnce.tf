
# --------------------------------------------------------
# - Truyền thông với Internet thông qua NAT Instance
# - Cho phép quản lý Server thông qua Bastion Host
# - Các lưu luợng truy cập từ Client phải thông qua ALB
# --------------------------------------------------------

resource "aws_security_group" "sg-instance" {
  name = "terraform-sg-instance-${var.owner}"
  vpc_id = aws_vpc.vpc.id

  # Allows other hosts (in VPC) to communicate with it over TCP
  ingress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    self = true
    # cidr_blocks = [var.cidr-vpc]
  }

  # Allow 'ping' traffics to hosts in VPC
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [var.cidr-vpc]
  }

  tags = {
    Name = "terraform-sg-instance-${var.owner}"
  }
}

# Allow SSH conncetion form Bastion host:
resource "aws_security_group_rule" "sg-ingress-ssh-instance" {
  security_group_id = aws_security_group.sg-instance.id
  type = "ingress"

  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg-bastion.id
}

# Allow HTTP & HealthCheck request form ALB:
resource "aws_security_group_rule" "sg-ingress-http-HealthCheck-instance" {
  security_group_id = aws_security_group.sg-instance.id
  type = "ingress"

  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg-alb.id
}

# Allow Webserver to communicate with Internet through NAT Instance (setup packages, down source App,...):
resource "aws_security_group_rule" "sg-egress-internet-instance" {
  security_group_id = aws_security_group.sg-instance.id
  type = "egress"

  from_port = 0
  to_port = 65535
  protocol = "-1"
  source_security_group_id = aws_security_group.sg-bastion.id
}

# Allow MySQL traffic to RDS:
resource "aws_security_group_rule" "sg-egress-mysql-instance" {
  security_group_id = aws_security_group.sg-instance.id
  type = "egress"

  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg-rds.id
}
