#!/bin/bash

# Cloudflare Setup Script for Portfolio Website
# This script helps you set up Cloudflare WAF integration

set -e

echo "🚀 Cloudflare WAF Setup for Portfolio Website"
echo "=============================================="

# Check if config.json exists
if [ ! -f "config.json" ]; then
    echo "❌ Error: config.json not found!"
    echo "Please run the centralized configuration setup first."
    exit 1
fi

# Check if API token is set
API_TOKEN=$(grep -o '"api_token": "[^"]*"' config.json | cut -d'"' -f4)
if [ "$API_TOKEN" = "YOUR_CLOUDFLARE_API_TOKEN_HERE" ] || [ -z "$API_TOKEN" ]; then
    echo "⚠️  Warning: Cloudflare API token not configured!"
    echo ""
    echo "📋 Please follow these steps:"
    echo "1. Go to Cloudflare Dashboard → My Profile → API Tokens"
    echo "2. Create a custom token with these permissions:"
    echo "   - Zone:Zone:Read"
    echo "   - Zone:DNS:Edit"
    echo "   - Zone:Page Rules:Edit"
    echo "   - Zone:Zone Settings:Edit"
    echo "   - Zone:Cache Purge:Edit"
    echo "   - Zone:Firewall Services:Edit"
    echo "3. Copy the token and update config.json"
    echo "4. Run this script again"
    echo ""
    exit 1
fi

echo "✅ Cloudflare API token configured"
echo ""

# Check if domain is added to Cloudflare
echo "🔍 Checking Cloudflare domain configuration..."
DOMAIN=$(grep -o '"domain": "[^"]*"' config.json | cut -d'"' -f4)
SUBDOMAIN=$(grep -o '"subdomain": "[^"]*"' config.json | cut -d'"' -f4)

echo "Domain: $DOMAIN"
echo "Subdomain: $SUBDOMAIN"
echo ""

echo "📋 Prerequisites Checklist:"
echo "1. ✅ API Token configured"
echo "2. ⏳ Domain added to Cloudflare: $DOMAIN"
echo "3. ⏳ Nameservers updated in GoDaddy"
echo "4. ⏳ DNS propagation (up to 48 hours)"
echo ""

echo "🔧 Next Steps:"
echo "1. Add $DOMAIN to Cloudflare dashboard (choose FREE plan)"
echo "2. Update GoDaddy nameservers to:"
echo "   - ns1.cloudflare.com"
echo "   - ns2.cloudflare.com"
echo "3. Wait for DNS propagation"
echo "4. Run: terraform plan"
echo "5. Run: terraform apply"
echo ""

echo "📖 For detailed instructions, see: CLOUDFLARE_SETUP.md"
echo ""

# Check if Terraform is ready
if command -v terraform &> /dev/null; then
    echo "🔍 Checking Terraform configuration..."
    
    # Check if Cloudflare provider is configured
    if grep -q "cloudflare" main.tf; then
        echo "✅ Cloudflare provider configured in Terraform"
    else
        echo "❌ Cloudflare provider not found in main.tf"
    fi
    
    # Check if cloudflare.tf exists
    if [ -f "cloudflare.tf" ]; then
        echo "✅ Cloudflare configuration file found"
    else
        echo "❌ cloudflare.tf not found"
    fi
else
    echo "❌ Terraform not installed or not in PATH"
fi

echo ""
echo "🎯 Ready to deploy Cloudflare WAF!"
echo "Run 'terraform plan' to see what will be created."
