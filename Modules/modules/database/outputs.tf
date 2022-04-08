
output "sg_rds_id" {
  value = aws_security_group.sg-rds.id
}

output "db_endpoint" {
  value = aws_db_instance.terraform-rds-mysql.endpoint
}
