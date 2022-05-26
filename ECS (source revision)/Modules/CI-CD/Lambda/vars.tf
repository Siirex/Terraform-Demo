
variable "use_pipline" {
  type = bool
  default = false
}

# -----------------------

variable "function_log" {
  type = string
  default = ""
}

variable "role_log" {
  type = string
  default = ""
}

variable "handler_log" {
  type = string
  default = ""
}

variable "runtime_log" {
  type = string
  default = ""
}

/*
variable "file_function_log" {
  type = string
  default = ""
}
*/

# -----------------------

variable "bucket_id" {
  type = string
  default = ""
}

variable "bucket_function_log_key" {
  type = string
  default = ""
}

variable "bucket_function_build_key" {
  type = string
  default = ""
}

# -----------------------

variable "function_build" {
  type = string
  default = ""
}

variable "role_build" {
  type = string
  default = ""
}

variable "handler_build" {
  type = string
  default = ""
}

variable "runtime_build" {
  type = string
  default = ""
}

/*
variable "file_function_build" {
  type = string
  default = ""
}
*/

# ------------------------

variable "codecommit_repo_arn" {
  type = string
  default = ""
}

# --------------------------

variable "statement_allow" {
  type = string
  default = ""
}

variable "principal_allow" {
  type = string
  default = ""
}

variable "action_allow" {
  type = string
  default = ""
}
