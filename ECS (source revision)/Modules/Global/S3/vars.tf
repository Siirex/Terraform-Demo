
variable "use_pipline" {
  type = bool
  default = false
}

# -------------------------------

variable "bucket_function_name" {
  type = string
  default = ""
}

variable "bucket_function_acl" {
  type = string
  default = ""
}

variable "account_id" {
  type = list
  default = []
}

# -------------------------------

variable "bucket_codepipline_name" {
  type = string
  default = ""
}

variable "bucket_codepipline_acl" {
  type = string
  default = ""
}
