terraform {
  required_version = "=0.11.11"

  backend "s3" {
    bucket = "<bucket_name>"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  version = "1.57"
  region  = "us-east-1"
}
