variable "tag" {
  type        = string
  sensitive   = true
  description = "Tag do projeto e nome do bucket."
}
variable "cloudfront_distribution_id" {
  type        = string
  sensitive   = true
  description = "ID da distribuição CloudFront"
}

variable "file_zip" {
  type        = string
  sensitive   = true
  description = "Diretório do arquivo zip do projeto."
}

variable "github_pat" {
  type        = string
  sensitive   = true
  description = "Token do projeto."
}

variable "github_repo" {
  type        = string
  sensitive   = true
  description = "Repositório github do projeto."
}

variable "bucket" {
  type        = string
  sensitive   = true
  description = "Bucket do projeto."
}

variable "file" {
  type        = string
  sensitive   = true
  description = "Nome do arquivo do projeto."
}

variable "region" {
  type        = string
  sensitive   = true
  description = "Região utilizada no projeto."
}
