
# ------------------------------------------------------
# Store Function releases to S3 Bucket for each function

resource "aws_s3_bucket" "lambda" {
  bucket = var.bucket_function_name
}

resource "aws_s3_bucket_acl" "lambda" {
  bucket = aws_s3_bucket.lambda.id
  acl = var.bucket_function_acl
}

resource "aws_s3_bucket_versioning" "lambda" {
  bucket = aws_s3_bucket.lambda.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------------------------
# S3 Bucket for store Artifact of CodePipline

resource "aws_s3_bucket" "codepipline" {
  count = var.use_pipline ? 1 : 0
  bucket = var.bucket_codepipline_name
}

resource "aws_s3_bucket_acl" "codepipline" {
  count = var.use_pipline ? 1 : 0
  bucket = aws_s3_bucket.codepipline.id
  acl = var.bucket_codepipline_acl
}

resource "aws_s3_bucket_versioning" "codepipline" {
  count = var.use_pipline ? 1 : 0
  bucket = aws_s3_bucket.codepipline.id
  versioning_configuration {
    status = "Enabled"
  }
}
