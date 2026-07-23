variable "cloudfront_distribution_id" {
  type        = string
  description = "ID da distribuição CloudFront"
}

variable "mztool_zip" {
  type        = string
  description = "mztool.zip"
}

variable "github_pat" {
  type      = string
  sensitive = true
}

variable "github_repo" {
  type = string
  # exemplo: "mzti/mztool"
}
