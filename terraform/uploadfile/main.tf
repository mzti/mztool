#Reforça a região utilizada no projeto.
provider "aws" {
  region = var.region
}

#Verifica se o arquivo local está diferente do arquivo no bucket através da comparação de Hash MD5 e envia se for diferente.
resource "aws_s3_object" "file" {
  bucket      = var.bucket
  key         = var.file
  source      = var.file_zip
  source_hash = filemd5("${var.file_zip}")
  tags = {
    Name = "${var.tag}"
  }
}

#Aplica Invalidate no Cloudfront se o arquivo tiver sido modificado no bucket para garantir a última versão disponível.
resource "terraform_data" "invalidate_cloudfront" {
  depends_on = [aws_s3_object.file]

   input = aws_s3_object.file.etag

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /${var.file}"
  }
}
