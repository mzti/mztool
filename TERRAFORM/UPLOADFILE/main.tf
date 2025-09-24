resource "aws_s3_object" "mztool_zip" {
  bucket = "mztool"
  key    = "MZTOOL.zip"
  source = "K:\\OneDrive\\Área de Trabalho\\GITHUB\\DATA\\MZTOOL\\MZTOOL.zip"
  etag   = filemd5("K:\\OneDrive\\Área de Trabalho\\GITHUB\\DATA\\MZTOOL\\MZTOOL.zip")
}

output "mztool_zip_md5" {
  value = filemd5("K:\\OneDrive\\Área de Trabalho\\GITHUB\\DATA\\MZTOOL\\MZTOOL.zip")
}

resource "null_resource" "invalidate_cloudfront" {
  depends_on = [aws_s3_object.mztool_zip]

provisioner "local-exec" {
  command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /MZTOOL.zip"
}

}

# resource "null_resource" "invalidate_cloudfront" {
#   # Garante que só roda depois do upload do arquivo
#   depends_on = [aws_s3_object.mztool_zip]

#   provisioner "local-exec" {
#     command = <<EOT
#       aws cloudfront create-invalidation \
#         --distribution-id E2WXAENP66ZGFB \
#         --paths "/MZTOOL.zip"
#     EOT
#   }
# }


# resource "aws_cloudfront_invalidation" "invalidate_mztool_zip" {
#   distribution_id = E2WXAENP66ZGFB
#   paths           = ["/mztool.zip"]

#   Garante que só roda depois do upload
#   depends_on = [aws_s3_object.mztool_zip]
# }

