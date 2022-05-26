
variable "region" {
  default = "ap-southeast-1"
}

variable "acc_id" {
  default = "569377550849"
}

# --------------------------------------------

variable "ecr_repo_name" {
  default = "terraform"
}

variable "image_tag_setting" {
  type = string
  default = "IMMUTABLE"
}

variable "codecommit_repo_name" {
  default = "terraform"
}

# --------------------------------------------

variable "bucket_function_acl" {
  type = string
  default = "public"
}

variable "allow_acc_id" {
  type = string
  default = "569377550849"
}

# --------------------------------------------

variable "fucntion_logs_name" {
  default = "terraform_function_CloudWatchLogs"
}

variable "fucntion_build_name" {
  default = "terraform_function_CodeBuild"
}

variable "hander_function_log" {
  type = string
  default = "function_logs.entrypoint"
}

variable "runtime_function_log" {
  type = string
  default = "python3.8"
}

variable "hander_function_build" {
  type = string
  default = "function_codebuild.lambda_handler"
}

variable "runtime_function_build" {
  type = string
  default = "python3.8"
}

variable "key_store_function_log" {
  type = string
  default = "trigger_logs.zip"
}

variable "key_store_function_build" {
  type = string
  default = "trigger_buid.zip"
}

# --------------------------------------------

variable "sns_subscription_type" {
  type = string
  default = "email"
}

variable "sns_subscription_mail" {
  type = string
  default = "djhoangphances@gmail.com"
}

# --------------------------------------------

variable "branch_codecommit" {
  type = string
  default = "main"
}

variable "codecommit_events" {
  type = list
  default = [ "all" ]
}

# --------------------------------------------

variable "codebuild_project_name" {
  type = string
  default = "terraform_codebuild"
}

variable "sg_source_ingress" {
  type = list
  default = [ "150.222.78.0/24" ] //for ap-southeast-1 | check: https://ip-ranges.amazonaws.com/ip-ranges.json
}

variable "artifact" {
  type = string
  default = "NO_ARTIFACTS" //if use CodePipLine, "CODEPIPLINE"
}

variable "compute_type" {
  type = string
  default = "BUILD_GENERAL1_SMALL" // (3 GB memory + 2 vCPUs) is only valid if type is set to LINUX_CONTAINER
}

variable "image" {
  type = string
  default = "aws/codebuild/standard:3.0"
}

variable "type" {
  type = string
  default = "LINUX_CONTAINER"
}

variable "image_pull_credentials" {
  type = string
  default = "CODEBUILD"
}

variable "source_type" {
  type = string
  default = "CODECOMMIT"
}

