
resource "aws_db_instance" "terraform-rds-mysql" {
  identifier = "terraform mysql"

  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"

  # name = "" //database name too, but sometime error
  db_name = "terraformdb" //database name
  username = "siirex"
  password = "19981998"
  port = "3306"

  availability_zone = var.terraform-az-1a
  db_subnet_group_name = aws_db_subnet_group.terraform-subnet-group.id
  vpc_security_group_ids = [ "${aws_security_group.sg-centos-terraform.id}" ]
  
  publicly_accessible = true
  skip_final_snapshot = true
  final_snapshot_identifier = "terraform-final"
}
