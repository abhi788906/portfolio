# Cloudflare WAF Integration Setup Guide

This guide will help you set up Cloudflare WAF for your portfolio website with enterprise-grade security and performance optimizations.

## 🚀 Prerequisites

1. **Cloudflare Account**: Sign up at [cloudflare.com](https://cloudflare.com)
2. **Domain Ownership**: Your domain (`secada.in`) must be added to Cloudflare
3. **API Token**: Generate a Cloudflare API token with appropriate permissions

## 📋 Step-by-Step Setup

### Step 1: Add Domain to Cloudflare

1. **Log into Cloudflare Dashboard**
2. **Add Site**: Click "Add a Site" and enter `secada.in`
3. **Choose Plan**: Select "Free" plan (WAF features are limited but still effective)
4. **Update Nameservers**: 
   - GoDaddy → DNS Management → Nameservers
   - Replace with Cloudflare nameservers:
     ```
     ns1.cloudflare.com
     ns2.cloudflare.com
     ```
5. **Wait for Propagation**: DNS changes can take up to 48 hours

### Step 2: Generate API Token

1. **Go to Cloudflare Dashboard** → My Profile → API Tokens
2. **Create Custom Token** with these permissions:
   ```
   Zone:Zone:Read
   Zone:DNS:Edit
   Zone:Page Rules:Edit
   Zone:Zone Settings:Edit
   Zone:Cache Purge:Edit
   Zone:Firewall Services:Edit
   ```

3. **Copy the token** (you'll need it for Terraform)

### Step 3: Update Configuration

1. **Edit `config.json`:**
   ```json
   {
     "cloudflare": {
       "domain": "secada.in",
       "subdomain": "abhishek",
       "api_token": "YOUR_ACTUAL_API_TOKEN_HERE"
     }
   }
   ```

2. **Regenerate JavaScript configs:**
   ```bash
   node generate-config.js
   ```

### Step 4: Deploy Cloudflare Configuration

```bash
# Initialize Terraform with Cloudflare provider
terraform init

# Plan the changes
terraform plan

# Apply the configuration
terraform apply
```

## 🛡️ Security Features Enabled (Free Plan)

### WAF Protection
- **Managed WAF Rules**: Cloudflare's managed security rules
- **DDoS Protection**: Automatic DDoS mitigation
- **Basic Rate Limiting**: Built-in rate limiting protection
- **SSL/TLS**: Full SSL encryption

### Security Features
- **Basic WAF**: Managed security rules
- **DDoS Protection**: Automatic attack mitigation
- **SSL/TLS**: Full SSL with TLS 1.2+
- **HTTPS Redirects**: Automatic HTTP to HTTPS redirects

### Performance Features
- **Global CDN**: 200+ edge locations worldwide
- **Caching**: Aggressive caching for static assets
- **Compression**: Automatic compression
- **HTTP/2 & HTTP/3**: Modern protocol support

### SSL/TLS
- **Full SSL** (strict mode)
- **TLS 1.2+** required
- **TLS 1.3** enabled
- **Automatic HTTPS rewrites**

## ⚡ Performance Optimizations

### Caching
- **Cache everything** for static assets
- **4-hour browser cache** TTL
- **24-hour edge cache** TTL
- **Automatic cache purging**

### Compression & Optimization
- **Brotli compression** enabled
- **HTTP/2 and HTTP/3** enabled
- **Rocket Loader** for JavaScript optimization
- **CSS, HTML, JS minification**

### Page Rules
- **Aggressive caching** for all content
- **Automatic minification** of assets
- **HTTPS redirects** for all traffic

## 🔧 Configuration Details

### DNS Configuration
```hcl
# CNAME record pointing to CloudFront
resource "cloudflare_record" "website" {
  name    = "abhishek"
  value   = "d37bdiw604950r.cloudfront.net"
  type    = "CNAME"
  proxied = true  # Orange cloud (Cloudflare proxy)
}
```

### WAF Rules
```hcl
# Custom WAF rules for security
resource "cloudflare_ruleset" "waf_rules" {
  rules {
    action = "block"
    expression = "(http.request.uri.path contains \"/admin\")"
  }
}
```

### Rate Limiting
```hcl
# Rate limiting configuration
resource "cloudflare_ruleset" "rate_limiting" {
  rules {
    ratelimit {
      requests_per_period = 100
      period = 60
      mitigation_timeout = 300
    }
  }
}
```

## 🌐 Traffic Flow

```
User Request
    ↓
Cloudflare Edge (WAF + Rate Limiting)
    ↓
CloudFront Distribution
    ↓
S3 Bucket (Website Files)
```

## 📊 Monitoring & Analytics

### Cloudflare Analytics
- **Security events** in Cloudflare dashboard
- **Rate limiting** statistics
- **WAF rule triggers** and blocks
- **Performance metrics**

### Terraform Outputs
```bash
# View Cloudflare configuration
terraform output cloudflare_zone_id
terraform output cloudflare_dns_record
```

## 🔄 Updating Configuration

### Modify WAF Rules
1. **Edit `cloudflare.tf`**
2. **Update rules** as needed
3. **Apply changes**: `terraform apply`

### Change Rate Limits
```hcl
ratelimit {
  requests_per_period = 200  # Increase to 200 requests/minute
  period = 60
  mitigation_timeout = 600   # Increase timeout to 10 minutes
}
```

### Add Custom Rules
```hcl
rules {
  action = "block"
  expression = "(http.request.uri.path contains \"/malicious\")"
  description = "Block malicious paths"
  enabled = true
}
```

## 🚨 Troubleshooting

### Common Issues

1. **DNS Not Propagated**
   - Wait up to 48 hours
   - Check nameserver configuration
   - Verify domain in Cloudflare

2. **API Token Permissions**
   - Ensure token has all required permissions
   - Check token is valid and not expired

3. **WAF Rules Not Working**
   - Verify rules are enabled
   - Check rule expressions
   - Monitor Cloudflare logs

### Debug Commands
```bash
# Check DNS propagation
dig abhishek.secada.in

# Test Cloudflare proxy
curl -I https://abhishek.secada.in

# Verify Terraform state
terraform show
```

## 💰 Cost Considerations

### Cloudflare Plans
- **Free**: Basic protection, DDoS mitigation, SSL/TLS, CDN
- **Pro ($20/month)**: Custom WAF rules, advanced rate limiting, bot management
- **Business ($200/month)**: Advanced WAF, bot management, priority support
- **Enterprise**: Custom pricing, maximum protection

### Recommended: Free Plan
- ✅ DDoS protection
- ✅ Basic WAF (managed rules)
- ✅ SSL/TLS management
- ✅ Global CDN
- ✅ Performance optimizations
- ✅ Zero cost

## 🎯 Benefits

### Security
- 🛡️ **DDoS Protection**: Automatic mitigation
- 🔒 **WAF**: Custom security rules
- 🚫 **Rate Limiting**: Prevent abuse
- 🔍 **Bot Management**: Block malicious bots

### Performance
- ⚡ **Global CDN**: 200+ locations worldwide
- 🗜️ **Compression**: Brotli and Gzip
- 📦 **Caching**: Aggressive caching strategies
- 🚀 **HTTP/3**: Latest protocol support

### Reliability
- 🌐 **Uptime**: 99.9%+ availability
- 🔄 **Failover**: Automatic failover
- 📊 **Monitoring**: Real-time analytics
- 🛠️ **Support**: 24/7 support available

## ✅ Next Steps

1. **Complete DNS setup** in GoDaddy
2. **Wait for propagation** (up to 48 hours)
3. **Deploy Terraform configuration**
4. **Test security features**
5. **Monitor performance** and security events

Your portfolio website will now have enterprise-grade security and performance! 🎉
