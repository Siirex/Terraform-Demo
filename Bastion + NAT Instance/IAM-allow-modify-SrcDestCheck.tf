
# Theo mặc định, bản thân các EC2 Instance không có quyền thay đổi các Attributes của chính nó.
# Để NAT_instance có thể forward các packets từ Private Subnet ra và trở lại, cần phải tắt attribute "SrcDestCheck"

data "aws_iam_policy_document" "role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name = "terraform-nat-instance-${var.owner}"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["ec2:ModifyInstanceAttribute"] //permission allow modify attributes of EC2 Instance
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "policy" {
  name = "terraform-nat-instance-${var.owner}"
  policy = data.aws_iam_policy_document.policy.json
}

# ------------------------------------------------------------

resource "aws_iam_policy_attachment" "attach-role" {
  name = "terraform-nat-instance-${var.owner}"
  policy_arn = aws_iam_policy.policy.arn
  roles = [ aws_iam_role.role.id ]
}

resource "aws_iam_instance_profile" "nat-instance-profile" {
  name = "terraform-nat-instance-${var.owner}"
  role = aws_iam_role.role.id
}

