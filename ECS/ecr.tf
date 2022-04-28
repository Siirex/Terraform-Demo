
resource "aws_ecr_repository" "ecr" {
  name = "terraform"

  # Khả năng thay đổi Tags
  image_tag_mutability = "IMMUTABLE"

  # Scan iamge on Repo
  image_scanning_configuration {
    scan_on_push = true
  }
}


