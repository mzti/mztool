terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.8.0"
    }
  }
}

provider "aws" {
    region = "sa-east-1"
}

resource "aws_s3_bucket" "terraform_s3" {
    
    bucket = "mztool"
  
}