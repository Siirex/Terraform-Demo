
output "instance-centos-public-ip" {
  value = aws_instance.ec2-centos-terraform.public_ip
}

output "instance-centos-public-key" {
  value = aws_key_pair.terraform-centos-key.public_key
}

output "rds-mysql-endpoint" {
  value = aws_db_instance.terraform-rds-mysql.endpoint
}

# -------------------------------------------------------

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_region" {
  value = aws_s3_bucket.terraform_state.region
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.terraform_locks.arn
}

output "kms_key" {
  value = aws_kms_key.terraform-bucket-key-store-state.key_usage
}

output backend_configuration {

  value = <<BACKEND
          terraform {
            backend "s3" {
              bucket = "${aws_s3_bucket.terraform_state.bucket}"
              key = "terraform.tfstate"
              region = "${aws_s3_bucket.terraform_state.region}"

              dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
              encrypt = true
              kms_key_id = "${aws_kms_key.terraform-bucket-key-store-state.id}"
            }
          }
          BACKEND
}
