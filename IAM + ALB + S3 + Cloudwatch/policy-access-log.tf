
# --------------------------------------------------------------------------------------------------
# Bucket Policy (áp dụng cho S3 Bucket): Cho phép ALB được thao tác với S3 Bucket & Object
# --------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "log-bucket-policy" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = "${data.aws_iam_policy_document.log-bucket-policy.json}"
}

data "aws_elb_service_account" "main" {} 

data "aws_iam_policy_document" "log-bucket-policy" {

    statement {
    principals {
      type = "AWS"
      identifiers = [ 
        "${data.aws_elb_service_account.main.arn}"
        # "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
      ]
    }
    sid = "AllowELBRootAccount"
    effect = "Allow"
    actions = [ "s3:PutObject" ]
    resources = [
      "arn:aws:s3:::${var.bucket-alb-log}/${var.prefix-bucket-alb-log}/AWSLogs/${var.aws-account-id}/*"
    ]
  }
  statement {
    principals {
      type = "Service"
      identifiers = ["delivery.logs.amazonaws.com"] //service logging
    }
    sid = "AWSLogDelivery-Write"
    effect = "Allow"
    actions = [ "s3:PutObject" ]
    resources = [
      "arn:aws:s3:::${var.bucket-alb-log}/${var.prefix-bucket-alb-log}/AWSLogs/${var.aws-account-id}/*"
    ]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = ["bucket-owner-full-control"]
    }
  }
  statement {
    principals {
      type = "Service"
      identifiers = ["delivery.logs.amazonaws.com"] //service logging
    }
    sid = "AWSLogDelivery-AclCheck"
    effect = "Allow"
    actions = [ "s3:GetBucketAcl" ]
    resources = [
      aws_s3_bucket.alb_access_logs.arn
    ]
  }
}
