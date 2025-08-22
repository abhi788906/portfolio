variable "aws_region" {
  description = "AWS region for the S3 bucket and other resources"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for hosting the website"
  type        = string
  default     = "abhishek-portfolio-website"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be between 3 and 63 characters, contain only lowercase letters, numbers, dots, and hyphens, and start and end with a letter or number."
  }
}

variable "domain_name" {
  description = "Domain name for the website (e.g., abhishek.secada.in)"
  type        = string
  default     = "abhishek.secada.in"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID (leave empty if using GoDaddy DNS)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "enable_cloudfront_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront price class for cost optimization"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "acm_certificate_arn" {
  description = "ARN of existing ACM certificate (not needed when managing certificate directly with Terraform)"
  type        = string
  default     = ""
}

# Cloudflare Configuration
variable "cloudflare_api_token" {
  description = "Cloudflare API token for WAF and security configuration"
  type        = string
  sensitive   = true
}

variable "cloudflare_domain" {
  description = "Main domain name for Cloudflare (e.g., secada.in)"
  type        = string
  default     = "secada.in"
}

variable "cloudflare_subdomain" {
  description = "Subdomain for the website (e.g., abhishek)"
  type        = string
  default     = "abhishek"
}

 