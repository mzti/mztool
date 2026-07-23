resource "aws_s3_object" "mztool_zip" {
  bucket = "mztool"
  key    = "mztool.zip"
  source = "${var.mztool_zip}"
  etag   = filesha256("${var.mztool_zip}")
}

output "mztool_zip_sha256" {
  value = filesha256("${var.mztool_zip}")
}

resource "null_resource" "trigger_mztool_sign_workflow" {
  # depende do upload do ZIP
  depends_on = [
    aws_s3_object.mztool_zip
  ]

  provisioner "local-exec" {
    
    command = "curl -X POST -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer ${var.github_pat}\" -H \"X-GitHub-Api-Version: 2022-11-28\" https://api.github.com/repos/${var.github_repo}/actions/workflows/mztool-sign.yml/dispatches -d '{\"ref\":\"main\"}'"

  }
}

resource "null_resource" "invalidate_cloudfront" {
  depends_on = [aws_s3_object.mztool_zip]

provisioner "local-exec" {
  command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /mztool.zip"
}

}