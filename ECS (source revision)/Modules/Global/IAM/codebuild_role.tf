
resource "aws_iam_role" "codebuild_role" {
  assume_role_policy = data.aws_iam_policy_document.codebuild_role.json
  name = "terraform_iam_role_codebuild_logs"
}

data "aws_iam_policy_document" "codebuild_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [ "codebuild.amazonaws.com" ]
      type = "Service"
    }
  }
}

# -----------------------------------------------------------------------
# Allow Codebuild logging (build) to Cloudwatch Logs - & 

resource "aws_iam_policy" "codebuild_logs" {
  name = "terraform_iam_policy_codebuild_logs"
  path = "/terraform/"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
})
}

# -----------------------------------------------------------------------
# Allow pull source from CodeCommit Repo & push output artifact to S3:

resource "aws_iam_policy" "codebuild_base" {
  name = "terraform_iam_policy_codebuild_base"
  path = "/terraform/"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Resource": [
          "arn:aws:codecommit:*:*:*"
        ],
        "Action": [
          "CodeCommit:ListBranches",
          "CodeCommit:ListPullRequests",
          "CodeCommit:ListRepositories",
          "CodeCommit:BatchGetPullRequests",
          "CodeCommit:BatchGetRepositories",
          "CodeCommit:CancelUploadArchive",
          "CodeCommit:DescribePullRequestEvents",
          "CodeCommit:GetBlob",
          "CodeCommit:GetBranch",
          "CodeCommit:GetComment",
          "CodeCommit:GetCommentsForComparedCommit",
          "CodeCommit:GetCommentsForPullRequest",
          "CodeCommit:GetCommit",
          "CodeCommit:GetCommitHistory",
          "CodeCommit:GetCommitsFromMergeBase",
          "CodeCommit:GetDifferences",
          "CodeCommit:GetMergeConflicts",
          "CodeCommit:GetObjectIdentifier",
          "CodeCommit:GetPullRequest",
          "CodeCommit:GetReferences",
          "CodeCommit:GetRepository",
          "CodeCommit:GetRepositoryTriggers",
          "CodeCommit:GetTree",
          "CodeCommit:GetUploadArchiveStatus",
          "codecommit:GitPull"
        ]
      },
      # Có thể không cần các permission ở đây:
      {
        "Effect": "Allow",
        "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        "Resource": [
          "arn:aws:codebuild:*:*:*"
        ]
      }
    ]
})
}

# -----------------------------------------------------------------------
# Allow CodeBuild access ECR Repo (push image to ECR):

resource "aws_iam_policy" "codebuild_registry_ecr" {
  name = "terraform_iam_policy_codebuild_registry_ecr"
  path = "/terraform/"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:GetLifecyclePolicy",
            "ecr:GetLifecyclePolicyPreview",
            "ecr:ListTagsForResource",
            "ecr:DescribeImageScanFindings",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
        ],
        "Resource": "*"
      }
    ]
})
}

# -----------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logs.arn #CodeBuildCloudWatchLogsPolicy
}
resource "aws_iam_role_policy_attachment" "codebuild_base" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_base.arn #CodeBuildBasePolicy
}
resource "aws_iam_role_policy_attachment" "codebuild_registry_ecr" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_registry_ecr.arn #AmazonEC2ContainerRegistryPowerUser
}


# Ngoài ra, có thể cấp một số quyền liên quan đến Network
/*
resource "aws_iam_policy" "codebuild_logs" {
  name = "terraform_iam_policy_codebuild_logs"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Resource": "arn:aws:ec2:{{region}}:{{account-id}}:network-interface/*",var.aws_account["id"])}",
        "Condition": {
          "StringEquals": {
            "ec2:Subnet": [
              "arn:aws:ec2:{{region}}:{{account-id}}:subnet/[[subnets]]"
            ],
            "ec2:AuthorizedService": "codebuild.amazonaws.com"
          }
        }
      }
    ]
})
}
*/
