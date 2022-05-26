
variable "repo_name" {
  type = string
}

variable "branch" {
  type = string
  default = ""
}

variable "list_event" {
  type = list
  default = []
}

variable "trigger_sns_name" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

# ---------------------------------------

variable "use_pipline" {
  type = bool
  default = true
}

variable "trigger_function_build_name" {
  type = string
  default = ""
}

variable "function_build_arn" {
  type = string
  default = ""
}

variable "codebuild_name" {
  type = string
  default = ""
}
