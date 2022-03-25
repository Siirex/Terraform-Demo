
output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "arn-bucket-upload" {
  value = aws_s3_bucket.upload.arn
}

output "arn-bucket-log" {
  value = aws_s3_bucket.alb_access_logs.arn
}
