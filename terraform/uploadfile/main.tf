resource "aws_s3_object" "mztool_zip" {
  bucket = "mztool"
  key    = "MZTOOL.zip"
  source = "${var.mztool_zip}"
  etag   = filesha256("${var.mztool_zip}")
}

output "mztool_zip_sha256" {
  value = filesha256("${var.mztool_zip}")
}

resource "null_resource" "invalidate_cloudfront" {
  depends_on = [aws_s3_object.mztool_zip]

provisioner "local-exec" {
  command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /MZTOOL.zip"
}

}

