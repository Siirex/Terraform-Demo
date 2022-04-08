
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
  name = "terraform-nat-instance-${var.env}"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["ec2:ModifyInstanceAttribute"] //permission allow modify attributes of EC2 Instance
    resources = ["*"]
    effect    = "${var.Allow-ModifyInstanceAttribute}" //true or false?
  }
}

resource "aws_iam_policy" "policy" {
  name = "terraform-nat-instance-${var.env}"
  policy = data.aws_iam_policy_document.policy.json
}

# ------------------------------------------------------------

resource "aws_iam_policy_attachment" "attach-role" {
  name = "terraform-nat-instance-${var.env}"
  policy_arn = aws_iam_policy.policy.arn
  roles = [ aws_iam_role.role.id ]
}

resource "aws_iam_instance_profile" "nat-instance-profile" {
  name = "terraform-nat-instance-${var.env}"
  role = aws_iam_role.role.id
}
