

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = "${var.bucket-alb-log}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "acl-bucket-log" {
  bucket = aws_s3_bucket.alb_access_logs.bucket
  acl = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "crypt-bucket-logging" {
  bucket = aws_s3_bucket.alb_access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "private-bucket-log" {
  bucket = aws_s3_bucket.alb_access_logs.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
