
resource "aws_codebuild_project" "build" {
  name = var.name
  build_timeout = "5" //(minutes)
  service_role = var.role

  # Information about the build output artifacts for the build project
  artifacts {
    type = var.artifact
  }

  # CodeBuild jobs allow for caching and build artifact management in S3
  /*
  cache {
    type     = "S3"
    location = aws_s3_bucket.example.bucket
  }
  */

  environment {
    compute_type = var.compute_type
    image = var.image
    type = var.type

    # Cho phép chạy Docker deamon bên trong container
    privileged_mode = var.privileged_mode
    
    image_pull_credentials_type = var.image_pull_credentials

    /*
    dynamic "environment_variable" {
      for_each = var.env_vars
      content {
        name = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
    */
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.log_group_name
      stream_name = var.log_stream_name
    }
  }

  source {
    type = var.source_type
    location = var.source_location
    buildspec = var.buildspec_file
  }
}

