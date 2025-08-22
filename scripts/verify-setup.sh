#!/bin/bash

# Portfolio Setup Verification Script
# This script verifies that all dependencies and file paths are working correctly

set -e

echo "🔍 Verifying Portfolio Setup..."

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

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        print_success "✓ $1"
        return 0
    else
        print_error "✗ $1 (missing)"
        return 1
    fi
}

# Function to check if directory exists
check_directory() {
    if [ -d "$1" ]; then
        print_success "✓ $1/"
        return 0
    else
        print_error "✗ $1/ (missing)"
        return 1
    fi
}

# Function to check if command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "✓ $1"
        return 0
    else
        print_error "✗ $1 (not installed)"
        return 1
    fi
}

echo ""
print_status "Checking required tools..."
errors=0

check_command "aws" || ((errors++))
check_command "terraform" || ((errors++))
check_command "node" || ((errors++))

echo ""
print_status "Checking project structure..."
check_directory "../terraform" || ((errors++))
check_directory "../src" || ((errors++))
check_directory "../scripts" || ((errors++))
check_directory "../docs" || ((errors++))
check_directory "../assets" || ((errors++))
check_directory "../deployments" || ((errors++))

echo ""
print_status "Checking Terraform files..."
check_file "../terraform/main.tf" || ((errors++))
check_file "../terraform/variables.tf" || ((errors++))
check_file "../terraform/locals.tf" || ((errors++))
check_file "../terraform/terraform.tfvars" || ((errors++))
check_file "../terraform/billing-api.tf" || ((errors++))
check_file "../terraform/cloudflare.tf" || ((errors++))

echo ""
print_status "Checking source files..."
check_file "../src/index.html" || ((errors++))
check_file "../src/config.json" || ((errors++))
check_file "../src/aws-billing-api.js" || ((errors++))
check_file "../src/generate-config.js" || ((errors++))

echo ""
print_status "Checking deployment scripts..."
check_file "deploy.sh" || ((errors++))
check_file "deploy-billing-api.sh" || ((errors++))
check_file "setup-cloudflare.sh" || ((errors++))
check_file "deploy.bat" || ((errors++))

echo ""
print_status "Checking documentation..."
check_file "../docs/README.md" || ((errors++))
check_file "../docs/CONFIGURATION.md" || ((errors++))
check_file "../docs/CLOUDFLARE_SETUP.md" || ((errors++))
check_file "../docs/GODADDY_DNS_SETUP.md" || ((errors++))
check_file "../docs/COST_ESTIMATION.md" || ((errors++))

echo ""
print_status "Checking assets..."
check_directory "../assets/images" || ((errors++))
check_directory "../assets/js" || ((errors++))
check_file "../assets/Abhishek_Gupta_Resume.pdf" || ((errors++))

echo ""
print_status "Testing configuration generation..."
if cd ../src && node generate-config.js > /dev/null 2>&1; then
    print_success "✓ Configuration generation works"
else
    print_error "✗ Configuration generation failed"
    ((errors++))
fi

echo ""
print_status "Testing Terraform configuration..."
if cd ../terraform && terraform validate > /dev/null 2>&1; then
    print_success "✓ Terraform configuration is valid"
else
    print_warning "⚠ Terraform validation failed (may need initialization)"
fi

echo ""
if [ $errors -eq 0 ]; then
    print_success "🎉 All checks passed! Your portfolio setup is ready."
    echo ""
    echo "📋 Next steps:"
    echo "   1. Configure AWS credentials: aws configure"
    echo "   2. Initialize Terraform: cd terraform && terraform init"
    echo "   3. Deploy infrastructure: terraform apply"
    echo "   4. Deploy website: cd ../scripts && ./deploy.sh"
else
    print_error "❌ Found $errors issue(s). Please fix them before proceeding."
    echo ""
    echo "🔧 Common fixes:"
    echo "   - Install missing tools (AWS CLI, Terraform, Node.js)"
    echo "   - Run: cd src && node generate-config.js"
    echo "   - Check file permissions on scripts"
fi

echo ""
