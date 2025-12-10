########################################
# AWS Provider
########################################
provider "aws" {
  region = "us-east-1"
}

########################################
# S3 Bucket for Terraform State
########################################
resource "aws_s3_bucket" "tf_state" {
  bucket = "cs-tf-state-surya-2025"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

########################################
# DynamoDB Table for Terraform State Locking
########################################
resource "aws_dynamodb_table" "tf_locks" {
  name         = "cs-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

########################################
# IAM Role for AWS CodeBuild
########################################
resource "aws_iam_role" "codebuild_role" {
  name = "cs-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

########################################
# Attach AWS Managed CodeBuild Policy
########################################
resource "aws_iam_role_policy_attachment" "codebuild_basic" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloper"
}

########################################
# Inline IAM Policy to Allow CodeBuild to Upload Report to S3
########################################
resource "aws_iam_role_policy" "codebuild_s3" {
  name = "cs-s3-upload"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Bucket-level permissions
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.tf_state.arn
      },

      # Object-level permissions inside /reports/*
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.tf_state.arn}/reports/*"
      }
    ]
  })
}

resource "aws_codebuild_project" "repo_doctor" {
  name         = "cs-repo-doctor"
  service_role = aws_iam_role.codebuild_role.arn
  source {
    type      = "GITHUB"
    location  = "https://github.com/SuryaPrakashReddy99/cloud-stethoscope.git"
    buildspec = "buildspec.yml"
  }
  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    privileged_mode = false
  }
  artifacts {
    type = "NO_ARTIFACTS"   # we already push to S3
  }
}