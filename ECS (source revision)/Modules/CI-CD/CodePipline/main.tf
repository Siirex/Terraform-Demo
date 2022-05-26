
resource "aws_codepipeline" "pipline" {
  name = var.name
  role_arn = var.role_pipline

  artifact_store {
    location = var.bucket_store_artifact
    type = "S3"

    /*
    encryption_key {
      id   = aws_kms_key.example.arn
      type = "KMS"
    }
    */
  }

  # Một pipline thường bao gồm các Stage:
  # -- Source (CodeCommit/GitHub/...)
  # -- Build (CodeBuild)
  # -- Deploy (CodeDeploy)
  
  stage {
    name = var.stage_source
    action {
      run_order = 1
      name = var.stage_source
      category = var.stage_source //xác định loại action có thể được thực hiện trong giai đoạn này
      owner = var.owner_action
      version = "1"
      
      # Service được call bởi action của Stage 'source'
      provider = var.provider_stage_source

      # Khai báo đầu ra Output Artifact của Stage 'source'
      output_artifacts = var.output_artifacts_stage_source

      # Configuration for provider
      # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeCommit.html
      configuration = {
        RepositoryName = var.repo_name
        BranchName = var.repo_branch
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = var.stage_build
    action {
      run_order = 1
      name = var.stage_build
      category = var.stage_build
      owner = var.owner_action
      version = "1"

      region = var.region
      
      # Service (CodeBuild) được call bởi action của Stage 'build'
      provider = var.provider_stage_build

      # Khai báo Output & Input Artifact của Stage 'build'
      input_artifacts = var.input_artifacts_stage_build //var.output_artifacts_stage_source
      output_artifacts = var.output_artifacts_stage_build //chứa file định nghĩa imagedefinition.json

      # Configuration for provider
      # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeBuild.html
      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  /*
  stage {
    name = "ManualApprove"
    action {
      run_order = 1
      name = "ManualApprove"
      category = "Approval"
      provider = "Approval"
    }
  }
  */

  stage {
    name = var.stage_deploy
    action {
      run_order = 1
      name = var.stage_deploy
      category = var.stage_deploy
      owner = var.owner_action
      version = "1"

      region = var.region

      # Service (CodeDeploy) được call bởi action của Stage 'deploy'
      provider = var.provider_stage_deploy

      # Khai báo Input Artifact của Stage 'deploy'
      input_artifacts = var.input_artifacts_stage_deploy //var.output_artifacts_stage_build

      # Configuration for provider
      # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeDeploy.html
      configuration = {
        ApplicationName = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_deployment_group_name

        # Configuration for Bule/Green deployment
        TaskDefinitionTemplateArtifact = var.TaskDefinitionTemplateArtifact
        TaskDefinitionTemplatePath = var.TaskDefinitionTemplatePath
        AppSpecTemplateArtifact = var.AppSpecTemplateArtifact
        AppSpecTemplatePath = var.AppSpecTemplatePath
        Image1ArtifactName = var.Image1ArtifactName
        Image1ContainerName = var.Image1ContainerName
      }
    }
  }
}



