provider "aws" {
  region = "us-east-1"
}
# trigger CI

# Bucket that will hold our pictures
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

# DynamoDB toy-lock table
resource "aws_dynamodb_table" "tf_locks" {
  name         = "cs-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}