terraform {
  backend "s3" {
    bucket         = "cs-tf-state-surya-2025"   # change YOURNAME
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cs-tf-locks"
    encrypt        = true
  }
}