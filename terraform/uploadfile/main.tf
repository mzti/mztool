provider "aws" {
  region = var.region
}

resource "aws_s3_object" "file" {
  bucket = var.bucket
  key    = var.file
  source = var.file_zip
   source_hash = filemd5("${var.file_zip}")
}


resource "null_resource" "trigger_file_sign_workflow" {
  # depende do upload do ZIP
  depends_on = [
    aws_s3_object.file
  ]

  provisioner "local-exec" {

    command = "curl -X POST -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer ${var.github_pat}\" -H \"X-GitHub-Api-Version: 2022-11-28\" https://api.github.com/repos/${var.github_repo}/actions/workflows/mztool-sign.yml/dispatches -d '{\"ref\":\"main\"}'"

  }
}

resource "null_resource" "invalidate_cloudfront" {
  depends_on = [aws_s3_object.file]

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /${var.file}"
  }

}