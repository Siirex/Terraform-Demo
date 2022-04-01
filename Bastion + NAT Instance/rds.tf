
resource "aws_db_instance" "terraform-rds-mysql" {
  identifier = "terraform-mysql-${var.owner}"

  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"

  # db_name = var.db-name
  name = var.db-name
  username = var.db-username
  password = var.db-pass
  port = "3306"

  availability_zone = var.azs[0]
  db_subnet_group_name = aws_db_subnet_group.subnet-group.id
  vpc_security_group_ids = [ aws_security_group.sg-rds.id ]
  
  publicly_accessible = true
  skip_final_snapshot = true
  final_snapshot_identifier = "terraform-final"
}

