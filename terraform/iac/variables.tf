variable "tag" {
  type        = string
  sensitive   = true
  description = "Tag do projeto e nome do bucket."
}

variable "tfstate_backup" {
  type        = string
  sensitive   = true
  description = "Bucket para fazer backup do tfstate."
}

variable "cloudfront_distribution_id" {
  type        = string
  sensitive   = true
  description = "ID da distribuição CloudFront"
}

variable "region" {
  type        = string
  sensitive   = true
  description = "Região utilizada no projeto."
}