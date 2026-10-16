terraform {
  backend "s3" {
    bucket  = "backup-mztool-tf-state"
    key     = "tf-state-folder\terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
