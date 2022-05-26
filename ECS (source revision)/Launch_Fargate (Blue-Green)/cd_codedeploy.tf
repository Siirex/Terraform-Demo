
# Logging for new Task (revision docker image)
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/task-test__fargate/container-new-cicd"
  retention_in_days = 1
}
resource "aws_cloudwatch_log_stream" "log_stream" {
  name = "terraform-logs-for-new-task-test__fargate-"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

module "deploy" {
  source = "../Modules/CI-CD/CodeDeploy"

  # Application
  deploy_app_ecs_name = "terraform_deploy_ecs"
  deploy_ecs_platform = "ECS"

  # Deployment Group
  deployment_config_ecs = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_ecs_name = "deploy_ecs"
  codedeploy_for_ecs_role_arn = module.role.role_codedeploy

  # ECS configrution
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name

  # Traffics configruration
  listener_arns = [ module.alb.listener_arn ] //set listener ban đầu làm Production traffics // + "${module.alb.green_listener_arn[0]}"
  blue_target_name = module.alb.targetgroup_name
  green_target_name = module.alb.green_target_name[0]
}

module "pipline" {
  source = "../Modules/CI-CD/CodePipline"

  name = "terraform-pipline"
  role_pipline = module.role.role_codepipline

  # S3 Artifact store
  bucket_store_artifact = module.s3.bucket_codepipline_bucket[0]

  # Stage 'Source' ----------------------------------------------------------------------------------------------
  stage_source = "Source"
  owner_action = "AWS"
  provider_stage_source = "CodeCommit"
  output_artifacts_stage_source = [ "SourceArtifact" ]
  # Configuration for CodeCommit
  repo_name = var.codecommit_repo_name
  repo_branch = "main"

  # Stage 'Build' ----------------------------------------------------------------------------------------------
  stage_build = "Build"
  provider_stage_build = "CodeBuild"
  region = var.region
  input_artifacts_stage_build = [ "SourceArtifact" ] //trỏ từ output_artifacts của Stage 'Source'
  output_artifacts_stage_build = [ "ImageArtifact", "DefinitionArtifact" ] //xuất ra 2 data Artifact: data of SourceCodeCommit (task, appspec) + data of SourceImageECR (image)
  # Configuration for CodeBuild
  codebuild_project_name = "terraform_codebuild" //module.codebuild.build_project_name

  # Stage 'deploy' ----------------------------------------------------------------------------------------------
  stage_deploy = "Deploy"
  provider_stage_deploy = "CodeDeployToECS" //console: Amazon ECS (Blue/Green)
  input_artifacts_stage_deploy = [ "ImageArtifact", "DefinitionArtifact" ] // "ImageArtifact" sử dụng file imagedefinition.json ở quá trình Build
  # Configuration for CodeDeploy
  codedeploy_app_name = "terraform_deploy_ecs" //module.deploy.codedeploy_app_name
  codedeploy_deployment_group_name = module.deploy.codedeploy_deployment_group_name

  # Configuration for Bule/Green deployment
  TaskDefinitionTemplateArtifact = "DefinitionArtifact" //Input Artifact name - cung cấp file Task definition cho deployment action
  TaskDefinitionTemplatePath = "taskdef.json" //default - tên tệp Task Definition được lưu trữ trong Output_Artifact của stage Source (SourceArtifact) trên Pipline
  AppSpecTemplateArtifact = "DefinitionArtifact" //Input Artifact name - cung cấp file AppSpec cho deployment action
  AppSpecTemplatePath = "appspec.yml" //default - tên tệp AppSpec được lưu trữ trong Output_Artifact của stage Source (SourceArtifact) trên Pipline
  Image1ArtifactName = "ImageArtifact" //Input Artifact name - cung cấp Image cho deployment action
  Image1ContainerName = "IMAGE1_NAME" //default - chỉ định tên của Image sẽ được sử dụng khi cập nhật ECS
}
