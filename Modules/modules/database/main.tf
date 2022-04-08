
resource "aws_db_instance" "terraform-rds-mysql" {
  identifier = "terraform-mysql-${var.env}"

  allocated_storage = 5
  engine = var.engine
  engine_version = var.engine-version
  instance_class = var.type

  # db_name = var.db-name
  name = var.db-name
  username = var.username
  password = var.password
  port = var.port

  availability_zone = var.az
  db_subnet_group_name = var.subnet-group
  vpc_security_group_ids = [ aws_security_group.sg-rds.id ]
  
  publicly_accessible = var.public
  skip_final_snapshot = true
  final_snapshot_identifier = "terraform-final"
}

resource "aws_security_group" "sg-rds" {
  name = "terraform-sg-rds-${var.env}"
  vpc_id = var.vpc-id
}

