
resource "aws_security_group" "sg-alb" {
  name = "terraform-sg-alb-${var.owner}"
  vpc_id = aws_vpc.vpc.id

  # Cho phép lưu lượng truy cập HTTP(80) từ bất kỳ Client nào vào:
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép mọi mọi request ra ngoài Internet:
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "terraform-sg-alb-${var.owner}"
  }
}

