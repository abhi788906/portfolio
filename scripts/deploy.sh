#!/bin/bash

# Portfolio Website Deployment Script
# This script deploys the website to S3 after Terraform creates the infrastructure

set -e

echo "🚀 Starting Portfolio Website Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check if required files exist
if [ ! -f "../src/index.html" ]; then
    print_error "index.html not found in src directory"
    exit 1
fi

if [ ! -d "../assets" ]; then
    print_warning "assets directory not found. Only index.html will be deployed."
fi

# Function to get S3 bucket name from Terraform output
get_bucket_name() {
    local bucket_name
    bucket_name=$(cd ../terraform && terraform output -raw website_bucket_name 2>/dev/null || echo "")
    
    if [ -z "$bucket_name" ]; then
        print_error "Could not get S3 bucket name from Terraform output. Make sure to run 'terraform apply' first."
        exit 1
    fi
    
    echo "$bucket_name"
}

# Function to get CloudFront distribution ID
get_cloudfront_id() {
    local distribution_id
    distribution_id=$(cd ../terraform && terraform output -raw cloudfront_distribution_id 2>/dev/null || echo "")
    
    if [ -z "$distribution_id" ]; then
        print_error "Could not get CloudFront distribution ID from Terraform output."
        exit 1
    fi
    
    echo "$distribution_id"
}

# Main deployment function
deploy_website() {
    local bucket_name
    local cloudfront_id
    
    print_status "Getting infrastructure details from Terraform..."
    bucket_name=$(get_bucket_name)
    cloudfront_id=$(get_cloudfront_id)
    
    print_success "S3 Bucket: $bucket_name"
    print_success "CloudFront Distribution: $cloudfront_id"
    
    print_status "Syncing website files to S3..."
    
    # Create a temporary directory for deployment
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Copy files to temp directory maintaining structure
    cp ../src/index.html "$temp_dir/"
    if [ -d "../assets" ]; then
        cp -r ../assets "$temp_dir/"
    fi
    
    # Sync files from temp directory to S3 bucket
    if aws s3 sync "$temp_dir" "s3://$bucket_name" \
        --delete \
        --cache-control "max-age=31536000" \
        --metadata-directive REPLACE; then
        
        print_success "Website files uploaded to S3 successfully!"
    else
        print_error "Failed to upload website files to S3"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Clean up temp directory
    rm -rf "$temp_dir"
    
    # Set proper content types for HTML files
    print_status "Setting proper content types..."
    aws s3 cp "s3://$bucket_name/index.html" "s3://$bucket_name/index.html" \
        --content-type "text/html" \
        --cache-control "no-cache" \
        --metadata-directive REPLACE
    
    # Set content types for CSS and JS files if they exist
    if [ -d "../assets" ]; then
        print_status "Setting content types for assets..."
        
        # Find and set content types for CSS files
        find ../assets -name "*.css" -exec aws s3 cp "s3://$bucket_name/{}" "s3://$bucket_name/{}" \
            --content-type "text/css" \
            --cache-control "max-age=31536000" \
            --metadata-directive REPLACE \;
        
        # Find and set content types for JS files
        find ../assets -name "*.js" -exec aws s3 cp "s3://$bucket_name/{}" "s3://$bucket_name/{}" \
            --content-type "application/javascript" \
            --cache-control "max-age=31536000" \
            --metadata-directive REPLACE \;
    fi
    
    print_success "Content types set successfully!"
    
    # Invalidate CloudFront cache
    print_status "Invalidating CloudFront cache..."
    if aws cloudfront create-invalidation \
        --distribution-id "$cloudfront_id" \
        --paths "/*" > /dev/null 2>&1; then
        
        print_success "CloudFront cache invalidation initiated!"
        print_status "Cache invalidation may take 5-10 minutes to complete."
    else
        print_warning "Failed to invalidate CloudFront cache. You may need to do this manually."
    fi
    
    # Get website URL
    local website_url
    website_url=$(cd ../terraform && terraform output -raw website_url 2>/dev/null || echo "https://$bucket_name.s3.amazonaws.com")
    
    print_success "🎉 Website deployment completed successfully!"
    echo ""
    echo "📱 Your website is now available at:"
    echo "   $website_url"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Wait for CloudFront cache invalidation (5-10 minutes)"
    echo "   2. Update your GoDaddy DNS settings:"
    echo "      - Create an A record for 'abhishek.secada.in'"
    echo "      - Point it to: $(cd ../terraform && terraform output -raw cloudfront_domain_name)"
    echo "   3. Wait for DNS propagation (up to 48 hours)"
    echo ""
    echo "📊 To monitor your deployment:"
    echo "   - CloudFront Distribution: $cloudfront_id"
    echo "   - S3 Bucket: $bucket_name"
}

# Check if we're in the right directory
if [ ! -f "../terraform/main.tf" ]; then
    print_error "main.tf not found. Please run this script from the scripts directory."
    exit 1
fi

# Check if Terraform has been initialized
if [ ! -d "../terraform/.terraform" ]; then
    print_status "Terraform not initialized. Running 'terraform init'..."
    if cd ../terraform && terraform init; then
        print_success "Terraform initialized successfully!"
    else
        print_error "Failed to initialize Terraform"
        exit 1
    fi
fi

# Run the deployment
deploy_website 