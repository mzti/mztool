#Busca as informações da conta AWS atual.
data "aws_caller_identity" "current" {}

#Define a região do projeto.
provider "aws" {
  region = var.region
}

#Cria o bucket do projeto.
resource "aws_s3_bucket" "bucket" {

  bucket = var.tag
  #Permissão para limpar os arquivos dentro do bucket e deletar o bucket.
  force_destroy = true
  #Forçar a região.
  provider = aws

}

#Cria o bucket para backup do tfstate do projeto.
resource "aws_s3_bucket" "bucket_tfstate" {

  bucket = var.tfstate_backup
  #Permissão para limpar os arquivos dentro do bucket e deletar o bucket.
  force_destroy = true

}

# Cria o Origin Access Control que será utilizado pelo CloudFront para acessar o S3.
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${var.tag}" # Dá um nome usando a sua tag
  description                       = "Chave de acesso seguro para o S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront" {
  aliases             = []
  anycast_ip_list_id  = null
  comment             = null
  default_root_object = null
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  staging             = false
  tags = {
    Name = "${var.tag}"
  }
  tags_all = {
    Name = "${var.tag}"
  }
  wait_for_deployment = true
  web_acl_id          = null
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    field_level_encryption_id  = null
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = null
    realtime_log_config_arn    = null
    response_headers_policy_id = null
    smooth_streaming           = false
    target_origin_id           = "${var.tag}.s3.${var.region}.amazonaws.com"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"
    grpc_config {
      enabled = false
    }
  }
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = "${var.tag}.s3.${var.region}.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "${var.tag}.s3.${var.region}.amazonaws.com"
    origin_path              = null
  }
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn            = null
    cloudfront_default_certificate = true
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = null
  }
}

#Autoriza o CloudFront a ler o S3 privado através da política do bucket.
resource "aws_s3_bucket_policy" "cloudfront_bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"

        # Usa o seu var.tag de forma segura para montar o ARN do Bucket
        Resource = "arn:aws:s3:::${var.tag}/*"

        Condition = {
          StringEquals = {
            # Monta o SourceArn usando a sua conta AWS e a sua variável do CloudFront
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"
          }
        }
      }
    ]
  })
}



