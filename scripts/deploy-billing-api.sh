#!/bin/bash

# AWS Billing API Deployment Script

set -e

echo "🚀 Deploying AWS Billing API..."

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

# Check if required files exist
if [ ! -f "../src/aws-billing-api.js" ]; then
    print_error "aws-billing-api.js not found in src directory"
    exit 1
fi

if [ ! -f "../terraform/billing-api.tf" ]; then
    print_error "billing-api.tf not found in terraform directory"
    exit 1
fi

# Create package.json for Lambda
print_status "Creating package.json for Lambda..."
cat > package.json << EOF
{
  "name": "portfolio-billing-api",
  "version": "1.0.0",
  "description": "AWS Billing API for Portfolio Website",
  "main": "aws-billing-api.js",
  "dependencies": {
    "aws-sdk": "^2.1000.0"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["aws", "billing", "lambda", "api"],
  "author": "Abhishek Gupta",
  "license": "MIT"
}
EOF

# Install dependencies
print_status "Installing dependencies..."
npm install --production

# Create deployment package
print_status "Creating deployment package..."
zip -r ../deployments/aws-billing-api.zip ../src/aws-billing-api.js node_modules/

print_success "Deployment package created: aws-billing-api.zip"

# Deploy with Terraform
print_status "Deploying with Terraform..."
cd ../terraform && terraform apply -target=aws_lambda_function.billing_api -target=aws_api_gateway_rest_api.billing_api -target=aws_api_gateway_deployment.billing_api_deployment

# Get API URL
API_URL=$(terraform output -raw billing_api_url 2>/dev/null || echo "")

if [ -n "$API_URL" ]; then
    print_success "Billing API deployed successfully!"
    echo ""
    echo "📊 API Endpoint: $API_URL"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Update the fetchAWSBilling() function in src/index.html"
    echo "   2. Replace the mock data with real API calls"
    echo "   3. Test the API endpoint"
    echo ""
    echo "🧪 Test the API:"
    echo "   curl $API_URL"
else
    print_warning "Could not get API URL. Check Terraform outputs."
fi

# Cleanup
print_status "Cleaning up..."
rm -rf node_modules package.json package-lock.json

print_success "Deployment completed!" 