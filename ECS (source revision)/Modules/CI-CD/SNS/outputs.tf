
output "topic_arn" {
  value = aws_sns_topic.topic.arn
}

output "topic_name" {
  value = aws_sns_topic.topic.name
}

# ----------------------------------

/*
output "topic_for_codebuild" {
  value = aws_sns_topic.codebuild.arn
}
*/
