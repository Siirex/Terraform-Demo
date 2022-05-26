
# ---------------------------------------------------------------
# SNS Topic & Subsciption - to call Lambda Function & send Mail

resource "aws_sns_topic" "topic" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "topic_mail" {
  topic_arn = aws_sns_topic.topic.arn
  protocol = var.topic_mail_protocol
  endpoint = var.topic_mail_destination
}

resource "aws_sns_topic_subscription" "topic_function_logs" {
  topic_arn = aws_sns_topic.topic.arn
  protocol = var.topic_function_protocol
  endpoint = var.topic_function_destination
}

# Permission for SNS topic calling (invoke) Lambda Function Log
resource "aws_lambda_permission" "sns_for_function_logs" {
  statement_id = var.statement_allow
  action = var.action_allow
  function_name = var.function_logs
  principal = var.principal_allow
  source_arn = aws_sns_topic.topic.arn
}


# ---------------------------------------------------------------
# SNS Topic - được trigger từ Events bắt được từ CodeBuild - để notification quá trình Build

/*
resource "aws_sns_topic" "codebuild" {
  name = var.topic_for_codebuild_name
}

resource "aws_sns_topic_policy" "codebuild" {
  arn = aws_sns_topic.codebuild.arn
  policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.codebuild.arn]
  }
}
*/
