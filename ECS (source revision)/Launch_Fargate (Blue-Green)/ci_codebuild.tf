
# ------------------------------------------------------------------------
# Lambda function: call CloudWatch Logs (logging for change on CodeCommit)

# Đã thiết lập Lambda lấy source function trên S3 bucket!!!
/*
data "archive_file" "function_log" {
  type = "zip"
  source_dir = "../Local Repostory/code-function"
  output_path = "../Local Repostory/code-function/function_logs.zip"
}
*/

module "s3" {
  source = "../Modules/Global/S3"

  # S3 Bucket for store source Lambda Function
  bucket_function_name = "lambda-functions-zip"
  bucket_function_acl = var.bucket_acl
  account_id = [ "${var.allow_acc_id}" ] //Bucket policy

  # S3 Bucket for store Artifact of CodePipline
  use_pipline = true
  bucket_codepipline_name = "codepipline-artifact-store"
  bucket_codepipline_acl = var.bucket_acl
}

resource "aws_cloudwatch_log_group" "fucntion_logs" {
  name = "/aws/lambda/${var.fucntion_logs_name}"
  retention_in_days = 1
}

module "function" {
  source = "../Modules/CI-CD/Lambda"

  # Function call CloudWatch Logs (trigger by SNS Topic from CodeCommit)
  function_log = var.fucntion_logs_name
  role_log = module.role.role_function_log
  handler_log = var.hander_function_log
  runtime_log = var.runtime_function_log
  # file_function_log = "${data.archive_file.function_log.output_path}"

  # Config S3 Bucket to release source functions
  bucket_id = module.s3.bucket_function_zip_id
  bucket_function_log_key = var.key_store_function_log

  use_pipline = true //--> Not use Function trigger CodeBuild anymore...
}


# ----------------------------------------------------
# Subcribe Mail + Lambda function 'log' with SNS Topic

module "sns" {
  source = "../Modules/CI-CD/SNS"

  # SNS topic được trigger từ các Events trong CodeCommit
  topic_name = "terraform_topic_for_codecommit"

  # subscription Mail for SNS topic
  topic_mail_protocol = var.sns_subscription_type
  topic_mail_destination = var.sns_subscription_mail

  # subscription Lambda function 'log' for SNS topic
  topic_function_protocol = "lambda"
  topic_function_destination = "arn:aws:lambda:${var.region}:${var.acc_id}:function:${var.fucntion_logs_name}"

  # permission for SNS invoke Lambda Function 'logs'
  statement_allow = "AllowSubscriptionToSNS"
  action_allow = "lambda:InvokeFunction"
  principal_allow = "sns.amazonaws.com"
  function_logs = var.fucntion_logs_name //module.function.function_logs_name

  # Topic for CodeBuild (notification of Build process)
  # topic_for_codebuild_name = "terraform_topic_for_codebuild"
}


# -------------------------------------------------------------------------------
# CodeCommit

module "repo_app" {
  source = "../Modules/CI-CD/CodeCommit"

  repo_name = var.codecommit_repo_name
  branch = var.branch_codecommit

  # Config trigger to SNS topic (notification mail & call Lambda Funtion 'log')
  trigger_sns_name = "terraform_trigger_sns"
  list_event = var.codecommit_events
  sns_topic_arn = module.sns.topic_arn

  # Config trigger to Lambda Function calling Codebuild?
  use_pipline = true //--> Not use Function anymore...
}


# -------------------------------------------------------------------------------
# CodeBuild

data "template_file" "buildspec" {
  template = file("../Local Repostory/Configuration CI&CD/buildspec-use-pipline.yml")
  vars = {
    acc_id = var.acc_id
    region = var.region
    repo_ecr_name = var.ecr_repo_name
    # folder = "App" //folder chứa CodeApp + Dockerfile (đã push lên CodeCommit)
  }
}

module "codebuild" {
  source = "../Modules/CI-CD/CodeBuild"

  # vpc_id = module.vpc.vpc_id
  # sg_source_ingress = var.sg_source_ingress

  name = var.codebuild_project_name
  role = module.role.codebuild_role_arn

  # Có sử dụng Input/Putput Artifact cho quá trình Build không?
  artifact = var.artifact

  compute_type = var.compute_type
  image = var.image
  type = var.type

  privileged_mode = true //allow run Docker deamon in Container
  image_pull_credentials = var.image_pull_credentials //(CODEBUILD) type of credentials AWS CodeBuild uses to pull images in your build

  /*
  env_vars {
    name = ""
    value = ""
  }
  */

  log_group_name = "/aws/codebuild/test_build"
  log_stream_name = "Build"

  # Config Repository - store source code
  source_type = var.source_type //codepipeline
  source_location = "https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.codecommit_repo_name}" //aws_codecommit_repository.example.clone_url_http
  
  # Config file setting for Build process (buildspec.yml)
  buildspec_file = data.template_file.buildspec.rendered
}


