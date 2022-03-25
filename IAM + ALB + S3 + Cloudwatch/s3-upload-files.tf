
resource "aws_s3_bucket" "upload" {
  bucket = var.bucket-upload
  force_destroy = true
}

resource "aws_s3_bucket_acl" "acl-bucket-data" {
  bucket = aws_s3_bucket.upload.bucket
  acl = "private" // or "public-read"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "crypt-bucket-data" {
  bucket = aws_s3_bucket.upload.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "private-bucket-upload" {
  bucket = aws_s3_bucket.upload.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "object-bucket-upload" {
  bucket = aws_s3_bucket.upload.id
  acl = "private" // or "public-read"
  key = var.object-upload
  source = "uploads/siirex.txt"

  # kms_key_id = "${aws_kms_key.examplekms.arn}"

  etag = filemd5("uploads/siirex.txt")
}

/*
resource "aws_kms_key" "examplekms" {
  deletion_window_in_days = 7
}
*/