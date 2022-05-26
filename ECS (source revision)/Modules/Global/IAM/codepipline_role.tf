
data "aws_iam_policy_document" "pipeline" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name = "terraform_iam_role_pipline"
  assume_role_policy = data.aws_iam_policy_document.pipeline.json
}

# CodePipeline policy needed to use CodeCommit and CodeBuild
resource "aws_iam_role_policy" "pipeline" {
  name = "terraform_iam_policy_pipline"
  role = aws_iam_role.pipeline.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ],
        "Resource": [
            "${var.build_artifact_bucket_arn}",
            "${var.build_artifact_bucket_arn}/*"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::codepipeline*",
          "arn:aws:s3:::elasticbeanstalk*"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*",
          "iam:PassRole"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate",
          "iam:PassRole"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ],
        "Resource": "${var.artifact_encryption_key_arn}",
        "Effect": "Allow"
      },
      {
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "*",
        "Effect": "Allow",
        "Condition": {
          "StringEqualsIfExists": {
            "iam:PassedToService": [ "ecs-tasks.amazonaws.com" ]
          }
        }
      }
    ]
  })
}

