
# ------------------------------------------------------------------------------------------
# - Only open 22 for connection from Internet - Giúp ngăn chặn các cuộc tấn công từ bên ngoài
# - Cho phép các Webserver liên lạc với bên ngoài thông qua NAT Instance
# ------------------------------------------------------------------------------------------

resource "aws_security_group" "sg-bastion" {
  name = "terraform-sg-bastion-${var.owner}"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép SSH, HTTP traffic, ... đi ra đến bất cứ nguồn nào
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "terraform-sg-bastion-${var.owner}"
  }
}

# Allow SSH connection to Webserver:
resource "aws_security_group_rule" "sg-egress-ssh-bastion" {
  security_group_id = aws_security_group.sg-bastion.id
  type = "egress"

  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg-instance.id
}

# Allow Webserver(s) to communicate with Internet (setup packages, down source App,...):
resource "aws_security_group_rule" "sg-egress-internet-nat-insatnce" {
  security_group_id = aws_security_group.sg-bastion.id
  type = "ingress"

  from_port = 0
  to_port = 65535
  protocol = "-1"
  source_security_group_id = aws_security_group.sg-instance.id
}
