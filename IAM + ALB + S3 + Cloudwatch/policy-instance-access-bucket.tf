
# -----------------------------------------------------------------------------------------------------------
# IAM Policy & Role (áp dụng cho ASG Instances): Cho phép ASG Instances được thao tác với S3 Bucket  & Object
# -----------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "iam-policy" {
  name = "terraform-iam-policy-for-insatnce"
  path = "/"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ManageObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket-upload}/*"
        ]
      },
      {
        Sid = "ManageBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket-upload}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "iam-role" {
  name = "terraform-iam-role-${var.owner}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowEC2"
        Effect = "Allow"
        Action = [ "sts:AssumeRole" ]
        Principal = {
          Service = "ec2.amazonaws.com" //service auto-scaling-group?
        }
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach-iam" {
  role = aws_iam_role.iam-role.id
  policy_arn = aws_iam_policy.iam-policy.arn
}

# Instance_Profile cho IAM Role (allow access S3 Bucket) sẽ được áp dụng cho các Instance trong ASG:
resource "aws_iam_instance_profile" "profile" {
  name = "profile-instance-${var.owner}"
  role = aws_iam_role.iam-role.id
}
