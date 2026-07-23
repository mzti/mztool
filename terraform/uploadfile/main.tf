# =====================================================
# UPLOAD S3 - DESABILITADO PARA TESTE
# =====================================================

# resource "aws_s3_object" "mztool_zip" {
#   bucket = "mztool"
#   key    = "mztool.zip"
#   source = "${var.mztool_zip}"
#   etag   = filesha256("${var.mztool_zip}")
# }

# output "mztool_zip_sha256" {
#   value = filesha256("${var.mztool_zip}")
# }


# =====================================================
# GITHUB DISPATCH TESTE
# =====================================================

resource "null_resource" "trigger_mztool_sign_workflow" {

  triggers = {
    test_run = timestamp()
  }

  # Mantido comentado para teste
  #
  # depends_on = [
  #   aws_s3_object.mztool_zip
  # ]


  # ===================================================
  # Workflow Dispatch
  # ===================================================

provisioner "local-exec" {

  environment = {
    GITHUB_PAT  = var.github_pat
    GITHUB_REPO = var.github_repo
  }

  command = "curl.exe -v -i -X POST -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer %GITHUB_PAT%\" -H \"X-GitHub-Api-Version: 2022-11-28\" https://api.github.com/repos/%GITHUB_REPO%/dispatches -d \"{\\\"event_type\\\":\\\"mztool-updated\\\"}\""

}



  # ===================================================
  # Repository Dispatch
  # ===================================================

  provisioner "local-exec" {

    environment = {
      GITHUB_PAT = var.github_pat
    }

    command = "curl -i -X POST -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer %GITHUB_PAT%\" -H \"X-GitHub-Api-Version: 2022-11-28\" https://api.github.com/repos/mzti/mztool/dispatches -d \"{\\\"event_type\\\":\\\"mztool-updated\\\"}\""

  }

}


# =====================================================
# CLOUDFRONT INVALIDATION - DESABILITADO PARA TESTE
# =====================================================

# resource "null_resource" "invalidate_cloudfront" {
#
#   depends_on = [
#     aws_s3_object.mztool_zip
#   ]
#
#   provisioner "local-exec" {
#     command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /mztool.zip"
#   }
#
# }
