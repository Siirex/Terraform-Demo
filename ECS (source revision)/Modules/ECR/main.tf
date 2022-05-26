
resource "aws_ecr_repository" "ecr" {
  name = var.repo_name

  image_tag_mutability = var.image_tag_setting

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

# Cấu hình chính sách lifecycle - đảm bảo kho lưu trữ ECR không bị cồng kềnh với quá nhiều image
resource "aws_ecr_lifecycle_policy" "service-base" {
  repository = "${aws_ecr_repository.service-base.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire tagged images older than 30 days",
            "selection": {
                "tagStatus": "tagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}