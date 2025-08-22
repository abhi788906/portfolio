#!/bin/bash

# Test Deployment Script
# This script tests if all assets are properly deployed and accessible

set -e

echo "🧪 Testing Portfolio Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get S3 bucket name from Terraform output
get_bucket_name() {
    local bucket_name
    bucket_name=$(cd ../terraform && terraform output -raw website_bucket_name 2>/dev/null || echo "")
    
    if [ -z "$bucket_name" ]; then
        print_error "Could not get S3 bucket name from Terraform output."
        return 1
    fi
    
    echo "$bucket_name"
}

# Function to get CloudFront distribution domain
get_cloudfront_domain() {
    local domain
    domain=$(cd ../terraform && terraform output -raw cloudfront_domain_name 2>/dev/null || echo "")
    
    if [ -z "$domain" ]; then
        print_error "Could not get CloudFront domain from Terraform output."
        return 1
    fi
    
    echo "$domain"
}

# Test S3 bucket contents
test_s3_contents() {
    local bucket_name="$1"
    
    print_status "Testing S3 bucket contents..."
    
    # Test if index.html exists
    if aws s3 ls "s3://$bucket_name/index.html" >/dev/null 2>&1; then
        print_success "✓ index.html found in S3"
    else
        print_error "✗ index.html not found in S3"
        return 1
    fi
    
    # Test if assets directory exists
    if aws s3 ls "s3://$bucket_name/assets/" >/dev/null 2>&1; then
        print_success "✓ assets/ directory found in S3"
    else
        print_error "✗ assets/ directory not found in S3"
        return 1
    fi
    
    # Test if images exist
    if aws s3 ls "s3://$bucket_name/assets/images/profile/" >/dev/null 2>&1; then
        print_success "✓ Profile images found in S3"
    else
        print_error "✗ Profile images not found in S3"
    fi
    
    # Test if certificates exist
    if aws s3 ls "s3://$bucket_name/assets/images/certificates/" >/dev/null 2>&1; then
        print_success "✓ Certificate images found in S3"
    else
        print_error "✗ Certificate images not found in S3"
    fi
    
    # Test if JS files exist
    if aws s3 ls "s3://$bucket_name/assets/js/config.js" >/dev/null 2>&1; then
        print_success "✓ config.js found in S3"
    else
        print_error "✗ config.js not found in S3"
    fi
    
    if aws s3 ls "s3://$bucket_name/assets/js/billing-config.js" >/dev/null 2>&1; then
        print_success "✓ billing-config.js found in S3"
    else
        print_error "✗ billing-config.js not found in S3"
    fi
}

# Test CloudFront accessibility
test_cloudfront_access() {
    local domain="$1"
    
    print_status "Testing CloudFront accessibility..."
    
    # Test main page
    if curl -s -o /dev/null -w "%{http_code}" "https://$domain" | grep -q "200"; then
        print_success "✓ Main page accessible via CloudFront"
    else
        print_error "✗ Main page not accessible via CloudFront"
    fi
    
    # Test assets
    if curl -s -o /dev/null -w "%{http_code}" "https://$domain/assets/js/config.js" | grep -q "200"; then
        print_success "✓ config.js accessible via CloudFront"
    else
        print_error "✗ config.js not accessible via CloudFront"
    fi
    
    # Test profile image
    if curl -s -o /dev/null -w "%{http_code}" "https://$domain/assets/images/profile/PXL_20221201_174040178.jpg" | grep -q "200"; then
        print_success "✓ Profile image accessible via CloudFront"
    else
        print_error "✗ Profile image not accessible via CloudFront"
    fi
}

# Main test function
main() {
    local bucket_name
    local cloudfront_domain
    
    print_status "Getting infrastructure details..."
    bucket_name=$(get_bucket_name) || exit 1
    cloudfront_domain=$(get_cloudfront_domain) || exit 1
    
    print_success "S3 Bucket: $bucket_name"
    print_success "CloudFront Domain: $cloudfront_domain"
    
    echo ""
    test_s3_contents "$bucket_name"
    echo ""
    test_cloudfront_access "$cloudfront_domain"
    
    echo ""
    print_success "🎉 Deployment test completed!"
    echo ""
    echo "📋 If you see any errors above:"
    echo "   1. Run the deployment script: ./deploy.sh"
    echo "   2. Wait for CloudFront cache invalidation (5-10 minutes)"
    echo "   3. Check S3 bucket permissions"
    echo "   4. Verify CloudFront distribution status"
}

# Run the test
main
