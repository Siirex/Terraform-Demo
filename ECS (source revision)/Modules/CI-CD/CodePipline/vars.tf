
variable "name" {
  type = string
}

variable "role_pipline" {
  type = string
}

variable "bucket_store_artifact" {
  type = string
}

# --------------------------------

variable "stage_source" {
  type = string
}

variable "owner_action" {
  type = string
}

variable "provider_stage_source" {
  type = string
}

variable "output_artifacts_stage_source" {
  type = list
}

variable "repo_name" {
  type = string
}

variable "repo_branch" {
  type = string
}

# --------------------------------

variable "stage_build" {
  type = string
}

variable "region" {
  type = string
}

variable "provider_stage_build" {
  type = string
}

variable "output_artifacts_stage_build" {
  type = list
}

variable "input_artifacts_stage_build" {
  type = list
}

variable "codebuild_project_name" {
  type = string
}

# --------------------------------

variable "stage_deploy" {
  type = string
}

variable "provider_stage_deploy" {
  type = string
}

variable "input_artifacts_stage_deploy" {
  type = list
}

variable "codedeploy_app_name" {
  type = string
}

variable "codedeploy_deployment_group_name" {
  type = string
}

# --------------------------------

variable "TaskDefinitionTemplateArtifact" {
  type = string
}

variable "TaskDefinitionTemplatePath" {
}

variable "AppSpecTemplateArtifact" {
  type = string
}

variable "AppSpecTemplatePath" {
}

variable "Image1ArtifactName" {
  type = string
}

variable "Image1ContainerName" {
  type = string
}

