# Load configuration from JSON file
locals {
  config = jsondecode(file("${path.module}/../src/config.json"))
  
  # Project configuration
  project_name    = local.config.project.name
  environment     = local.config.project.environment
  aws_region      = local.config.project.region
  
  # AWS resources
  bucket_name     = local.config.aws.bucket_name
  domain_name     = local.config.aws.domain_name
  
  # Billing API configuration
  billing_api_function_name = local.config.aws.billing_api.function_name
  billing_api_role_name     = local.config.aws.billing_api.role_name
  billing_api_policy_name   = local.config.aws.billing_api.policy_name
  
  # Terraform backend configuration
  terraform_state_bucket = local.config.aws.terraform.state_bucket
  terraform_state_key    = local.config.aws.terraform.state_key
  terraform_lock_table   = local.config.aws.terraform.lock_table
  
  # Contact information
  contact_email  = local.config.contact.email
  contact_website = local.config.contact.website
  
  # CloudFront configuration
  cloudfront_price_class = local.config.cloudfront.price_class
  enable_cloudfront_logging = local.config.cloudfront.enable_logging
  
  # Cloudflare configuration
  cloudflare_domain = local.config.cloudflare.domain
  cloudflare_subdomain = local.config.cloudflare.subdomain
  cloudflare_api_token = local.config.cloudflare.api_token
  
  # Common tags
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
