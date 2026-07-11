terraform {
  backend "s3" {
    bucket         = "backup-mztool-tf-state"
    key            = "tf-state-folder\terraform.tfstate"
    region         = "sa-east-1"
    encrypt        = true
  }
}
