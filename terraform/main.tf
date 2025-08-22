terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "abhishek-portfolio-terraform-state"
    key            = "portfolio-website/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = local.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Provider for ACM certificate (must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# S3 bucket for website hosting
resource "aws_s3_bucket" "website_bucket" {
  bucket = local.bucket_name
  
  tags = merge(local.common_tags, {
    Name = "Portfolio Website Bucket"
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "website_bucket_versioning" {
  bucket = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy for CloudFront access only
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website_distribution.arn
          }
        }
      }
    ]
  })
}





# ACM certificate resource
resource "aws_acm_certificate" "website_certificate" {
  provider = aws.us_east_1
  
  domain_name              = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method        = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Portfolio Website Certificate"
  }
}

# Use the ACM certificate ARN
locals {
  certificate_arn = aws_acm_certificate.website_certificate.arn
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  enabled             = true
  is_ipv6_enabled    = true
  default_root_object = "index.html"
  price_class         = local.cloudfront_price_class # Use only North America and Europe for cost optimization

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.website_oac.id
    origin_id                 = "S3-${aws_s3_bucket.website_bucket.bucket}"
  }

  aliases = [local.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    # Cache optimization for static assets
    compress = true
  }

  # Cache behavior for images and assets
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400  # 24 hours for assets
    max_ttl                = 31536000  # 1 year for assets

    compress = true
  }

  # Error page configuration
  custom_error_response {
    error_code         = 404
    response_code      = "200"
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = "200"
    response_page_path = "/index.html"
  }

  # HTTPS configuration
  viewer_certificate {
    acm_certificate_arn      = local.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Geographic restrictions (optional - remove if you want global access)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(local.common_tags, {
    Name = "Portfolio Website Distribution"
  })
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "website_oac" {
  name                              = "website-oac"
  description                       = "Origin Access Control for Portfolio Website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Route53 hosted zone (assuming you'll create this manually in GoDaddy or transfer to Route53)
# If you want to manage DNS through Route53, uncomment and configure this section
# resource "aws_route53_zone" "website_zone" {
#   name = var.domain_name
# }

# Route53 record for the website (only created if zone_id is provided)
resource "aws_route53_record" "website_record" {
  count = var.route53_zone_id != "" ? 1 : 0
  
  zone_id = var.route53_zone_id
  
  name    = local.domain_name
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Outputs
output "website_bucket_name" {
  description = "Name of the S3 bucket hosting the website"
  value       = aws_s3_bucket.website_bucket.bucket
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website_distribution.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

output "website_url" {
  description = "URL of the website"
  value       = "https://${local.domain_name}"
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = local.certificate_arn
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = aws_acm_certificate.website_certificate.status
}

output "acm_certificate_validation_records" {
  description = "DNS validation records for the ACM certificate"
  value = aws_acm_certificate.website_certificate.domain_validation_options
}

output "dns_configuration_instructions" {
  description = "DNS configuration instructions for GoDaddy"
  value = {
    domain_name = local.domain_name
    cloudfront_domain = aws_cloudfront_distribution.website_distribution.domain_name
    cloudfront_zone_id = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    instructions = [
      "1. Log into your GoDaddy account",
      "2. Go to DNS Management for secada.in",
      "3. Update nameservers to Cloudflare:",
      "   - ns1.cloudflare.com",
      "   - ns2.cloudflare.com",
      "4. Wait for DNS propagation (up to 48 hours)",
      "5. Cloudflare will automatically create the CNAME record"
    ]
  }
}

# Cloudflare Outputs
output "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  value       = data.cloudflare_zone.website.id
}

output "cloudflare_dns_record" {
  description = "Cloudflare DNS record details"
  value = {
    name  = local.cloudflare_subdomain
    value = aws_cloudfront_distribution.website_distribution.domain_name
    type  = "CNAME"
    proxied = true
  }
} 