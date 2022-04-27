
resource "aws_security_group" "sg-rds" {
  name = "terraform-sg-rds-${var.owner}"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-sg-rds-${var.owner}"
  }
}

# Allow MySQL traffics form Webserver:
resource "aws_security_group_rule" "sg-ingress-rds" {
  security_group_id = aws_security_group.sg-rds.id
  type = "ingress"

  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.sg-instance.id
}
