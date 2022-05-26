
resource "aws_codecommit_repository" "repo" {
  repository_name = var.repo_name
  default_branch = var.branch
}

resource "aws_codecommit_trigger" "repo" {
  repository_name = aws_codecommit_repository.repo.repository_name

  # Trigger to SNS Topic
  trigger {
    name = var.trigger_sns_name
    branches = [ "${var.branch}" ]
    events = var.list_event
    destination_arn = var.sns_topic_arn
  }

  # Trigger to Lambda Function, calling CodeBuild ?
  # If use_pipline is 'true', Infra will use CodePipline to trigger CodeBuild from CodeCommit events, no use Lambda Function anymore!
  dynamic "trigger" {
    for_each = var.use_pipline == true ? [] : [1]
    content {
      name = var.trigger_function_build_name
      branches = [ "${var.branch}" ]
      events = var.list_event
      destination_arn = var.function_build_arn 
      
      # Khai báo CodeBuild Project name muốn Lambda function call đến?
      custom_data = var.codebuild_name
    }
  }
}

