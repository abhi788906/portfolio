# 🚀 Portfolio Website - AWS Infrastructure

A modern, secure portfolio website hosted on AWS with CloudFront CDN, featuring a billing API and comprehensive infrastructure as code.

## 📁 Project Structure

This project is organized into logical directories for better maintainability:

```
portfolio/
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # Main AWS infrastructure
│   ├── variables.tf      # Variable definitions
│   ├── locals.tf         # Local variables and configuration
│   ├── billing-api.tf    # Billing API infrastructure
│   ├── cloudflare.tf     # Cloudflare configuration
│   └── terraform.tfvars  # Variable values
├── src/                  # Source files
│   ├── index.html        # Portfolio website
│   ├── config.json       # Centralized configuration
│   ├── aws-billing-api.js # AWS Lambda function
│   └── generate-config.js # Config generation script
├── scripts/              # Deployment and setup scripts
│   ├── deploy.sh         # Main deployment script
│   ├── deploy-billing-api.sh # Billing API deployment
│   ├── setup-cloudflare.sh   # Cloudflare setup
│   └── deploy.bat        # Windows deployment script
├── docs/                 # Documentation
│   ├── README.md         # Detailed setup guide
│   ├── CONFIGURATION.md  # Configuration guide
│   ├── CLOUDFLARE_SETUP.md # Cloudflare setup guide
│   ├── GODADDY_DNS_SETUP.md # DNS setup guide
│   └── COST_ESTIMATION.md # Cost estimation guide
├── assets/               # Website assets
│   ├── images/           # Images and certificates
│   ├── js/               # JavaScript files
│   └── Abhishek_Gupta_Resume.pdf # Resume
├── deployments/          # Deployment artifacts
│   └── *.zip            # Deployment packages
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Node.js (for config generation)

### 1. Configure the Project

```bash
# Generate configuration files
cd src
node generate-config.js
```

### 2. Deploy Infrastructure

```bash
# Initialize and apply Terraform
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Deploy Website

```bash
# Deploy website files
cd ../scripts
chmod +x deploy.sh
./deploy.sh
```

### 4. Deploy Billing API (Optional)

```bash
# Deploy the billing API
cd scripts
chmod +x deploy-billing-api.sh
./deploy-billing-api.sh
```

## 📚 Documentation

- **[Detailed Setup Guide](docs/README.md)** - Complete deployment instructions
- **[Configuration Guide](docs/CONFIGURATION.md)** - How to customize the project
- **[Cloudflare Setup](docs/CLOUDFLARE_SETUP.md)** - Cloudflare configuration
- **[DNS Setup](docs/GODADDY_DNS_SETUP.md)** - GoDaddy DNS configuration
- **[Cost Estimation](docs/COST_ESTIMATION.md)** - Monthly cost breakdown

## 🏗️ Architecture

- **S3 Bucket**: Static website hosting with private access
- **CloudFront**: Global CDN with HTTPS and caching
- **ACM**: SSL/TLS certificates
- **Lambda**: Serverless billing API
- **API Gateway**: REST API for billing data
- **Route53**: DNS management (optional)

## 🔒 Security Features

- Private S3 bucket with no public access
- CloudFront Origin Access Control (OAC)
- HTTPS enforcement with TLS 1.2+
- CORS configuration for web security
- IAM least privilege policies

## 💰 Cost Optimization

- CloudFront Price Class 100 (NA + EU)
- S3 lifecycle policies
- CloudFront caching optimization
- Minimal Lambda execution

## 🛠️ Development

### Adding New Features

1. **Infrastructure**: Add resources to `terraform/` files
2. **Website**: Modify `src/index.html`
3. **Configuration**: Update `src/config.json` and regenerate
4. **Scripts**: Add deployment scripts to `scripts/`

### Testing

```bash
# Test Terraform configuration
cd terraform
terraform plan

# Test deployment script
cd ../scripts
./deploy.sh --dry-run
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the [documentation](docs/)
2. Review the troubleshooting section in [docs/README.md](docs/README.md)
3. Open an issue on GitHub

---

**Built with ❤️ by Abhishek Gupta**
