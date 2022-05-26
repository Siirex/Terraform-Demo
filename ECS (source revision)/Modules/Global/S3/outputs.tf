
output "bucket_function_zip_id" {
  value = aws_s3_bucket.lambda.id
}

output "bucket_function_zip_arn" {
  value = aws_s3_bucket.lambda.arn
}

output "bucket_codepipline_bucket" {
  value = aws_s3_bucket.codepipline.*.bucket
}
