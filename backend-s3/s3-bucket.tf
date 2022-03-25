
resource "aws_s3_bucket" "terraform_state" {

  bucket = "terraform-store-state-${var.owner}"

  acl = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform-bucket-key-store-state.arn
        sse_algorithm = "aws:kms"
        # sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "terraform-store-state-${var.owner}"
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-lock-state-${var.owner}"
  
  # billing_mode = "PAY_PER_REQUEST"

  read_capacity  = 5
  write_capacity = 1

  hash_key = "LockID" //primary key for locking

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-lock-state-${var.owner}"
  }
}

