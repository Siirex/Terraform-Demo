
data "aws_iam_policy_document" "events" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [ "events.amazonaws.com" ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_events" {
  assume_role_policy = data.aws_iam_policy_document.events.json
  name = "terraform_ecs_events"
}

resource "aws_iam_policy" "ecs_events" {
  name = "terraform_ecs_events"
  path = "/terraform/"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ecs:RunTask"
        ],
        "Resource": "*" //aws_ecs_task_definition.example.arn
      }
    ]
})
}

resource "aws_iam_role_policy_attachment" "ecs_events" {
  role = aws_iam_role.ecs_events.name
  policy_arn = aws_iam_policy.ecs_events.arn
}

# ---------------------------------------------------------------------

/*
resource "aws_iam_role" "sns_events" {
  assume_role_policy = data.aws_iam_policy_document.events.json
  name = "terraform_sns_events"
}

resource "aws_iam_policy" "sns_events" {
  name = "terraform_sns_events"
  path = "/terraform/"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "SNS:Publish" 
        ],
        "Resource": "*" //aws_sns_topic.example.arn
      }
    ]
})
}

resource "aws_iam_role_policy_attachment" "sns_events" {
  role = aws_iam_role.sns_events.name
  policy_arn = aws_iam_policy.sns_events.arn
}
*/

