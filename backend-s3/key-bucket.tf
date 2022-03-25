
resource "aws_kms_key" "terraform-bucket-key-store-state" {
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_alias" "key-alias" {
  name = "alias/terraform-bucket-key-state"
  target_key_id = aws_kms_key.terraform-bucket-key-store-state.id
}
