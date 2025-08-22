# Cloudflare Provider Configuration
provider "cloudflare" {
  api_token = local.cloudflare_api_token
}

# Cloudflare Zone (domain)
data "cloudflare_zone" "website" {
  name = local.cloudflare_domain
}

# Cloudflare DNS Record for the website
resource "cloudflare_record" "website" {
  zone_id = data.cloudflare_zone.website.id
  name    = local.cloudflare_subdomain
  value   = aws_cloudfront_distribution.website_distribution.domain_name
  type    = "CNAME"
  ttl     = 1 # Auto (Cloudflare managed)
  proxied = true # Enable Cloudflare proxy (orange cloud)
}

# Note: Custom WAF rules require Pro plan or higher
# Free plan uses managed WAF rules only
# Custom rules are commented out for free plan compatibility

# Cloudflare WAF Custom Rules (Pro plan required)
# resource "cloudflare_ruleset" "waf_rules" {
#   zone_id = data.cloudflare_zone.website.id
#   name    = "Portfolio Website WAF Rules"
#   description = "WAF rules for portfolio website security"
#   kind    = "zone"
#   phase   = "http_request_firewall_custom"
#
#   rules {
#     action = "block"
#     expression = "(http.request.uri.path contains \"/admin\" or http.request.uri.path contains \"/wp-admin\" or http.request.uri.path contains \"/phpmyadmin\")"
#     description = "Block admin paths"
#     enabled = true
#   }
#
#   rules {
#     action = "block"
#     expression = "(http.request.uri.query contains \"union select\" or http.request.uri.query contains \"drop table\" or http.request.uri.query contains \"insert into\")"
#     description = "Block SQL injection attempts"
#     enabled = true
#   }
#
#   rules {
#     action = "block"
#     expression = "(http.request.uri.query contains \"<script\" or http.request.uri.query contains \"javascript:\")"
#     description = "Block XSS attempts"
#     enabled = true
#   }
#
#   rules {
#     action = "block"
#     expression = "(http.user_agent contains \"bot\" or http.user_agent contains \"crawler\" or http.user_agent contains \"spider\")"
#     description = "Block suspicious user agents"
#     enabled = true
#   }
# }

# Note: Advanced rate limiting requires Pro plan or higher
# Free plan has basic rate limiting only
# Advanced rate limiting is commented out for free plan compatibility

# Cloudflare Rate Limiting Rules (Pro plan required)
# resource "cloudflare_ruleset" "rate_limiting" {
#   zone_id = data.cloudflare_zone.website.id
#   name    = "Portfolio Website Rate Limiting"
#   description = "Rate limiting rules for portfolio website"
#   kind    = "zone"
#   phase   = "http_ratelimit"
#
#   rules {
#     action = "block"
#     expression = "true"
#     description = "Rate limit all requests"
#     enabled = true
#     ratelimit {
#       requests_per_period = 100
#       period = 60
#       mitigation_timeout = 300
#       counting_expression = "ip.src"
#     }
#   }
# }

# Note: Custom security level rules require Pro plan or higher
# Free plan uses default security settings
# Custom security rules are commented out for free plan compatibility

# Cloudflare Security Level (Pro plan required)
# resource "cloudflare_ruleset" "security_level" {
#   zone_id = data.cloudflare_zone.website.id
#   name    = "Portfolio Website Security Level"
#   description = "Set security level for portfolio website"
#   kind    = "zone"
#   phase   = "http_request_firewall_custom"
#
#   rules {
#     action = "managed_challenge"
#     expression = "true"
#     description = "Medium security level for all requests"
#     enabled = true
#   }
# }

# Note: Browser integrity check requires Pro plan or higher
# Free plan has basic browser checks only
# Browser integrity rules are commented out for free plan compatibility

# Cloudflare Browser Integrity Check (Pro plan required)
# resource "cloudflare_ruleset" "browser_integrity" {
#   zone_id = data.cloudflare_zone.website.id
#   name    = "Portfolio Website Browser Integrity"
#   description = "Browser integrity check for portfolio website"
#   kind    = "zone"
#   phase   = "http_request_firewall_custom"
#
#   rules {
#     action = "managed_challenge"
#     expression = "true"
#     description = "Enable browser integrity check"
#     enabled = true
#   }
# }

# Note: HTTPS redirect is handled by SSL/TLS settings
# The "automatic_https_rewrites" setting will handle HTTP to HTTPS redirects

# Note: Page Rules require Zone:Page Rules:Edit permission
# Commenting out until API token permissions are updated

# Cloudflare Page Rules for Performance
# resource "cloudflare_page_rule" "cache_everything" {
#   zone_id = data.cloudflare_zone.website.id
#   target = "${local.cloudflare_subdomain}.${local.cloudflare_domain}/*"
#   
#   actions {
#     cache_level = "cache_everything"
#     browser_cache_ttl = 14400 # 4 hours
#     edge_cache_ttl = 86400    # 24 hours
#   }
# }

# resource "cloudflare_page_rule" "minify" {
#   zone_id = data.cloudflare_zone.website.id
#   target = "${local.cloudflare_subdomain}.${local.cloudflare_domain}/*"
#   
#   actions {
#     minify {
#       css  = "on"
#       html = "on"
#       js   = "on"
#     }
#   }
# }

# Note: Zone Settings require Zone:Zone Settings:Edit permission
# Commenting out until API token permissions are updated

# Cloudflare SSL/TLS Settings
# resource "cloudflare_zone_settings_override" "ssl_settings" {
#   zone_id = data.cloudflare_zone.website.id
#   
#   settings {
#     ssl                      = "full"
#     min_tls_version          = "1.2"
#     opportunistic_encryption = "on"
#     tls_1_3                  = "on"
#     automatic_https_rewrites = "on"
#   }
# }

# Cloudflare Security Settings
# resource "cloudflare_zone_settings_override" "security_settings" {
#   zone_id = data.cloudflare_zone.website.id
#   
#   settings {
#     security_level           = "medium"
#     browser_check            = "on"
#     challenge_ttl            = 1800
#     privacy_pass             = "on"
#     security_header {
#       enabled = true
#       include_subdomains = true
#       preload = true
#       max_age = 31536000
#     }
#   }
# }

# Cloudflare Performance Settings
# resource "cloudflare_zone_settings_override" "performance_settings" {
#   zone_id = data.cloudflare_zone.website.id
#   
#   settings {
#     rocket_loader            = "on"
#     minify {
#       css  = "on"
#       html = "on"
#       js   = "on"
#     }
#     brotli                   = "on"
#     http2                    = "on"
#     http3                    = "on"
#     zero_rtt                 = "on"
#   }
# }
