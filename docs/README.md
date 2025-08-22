# Portfolio Website - AWS Infrastructure

This Terraform configuration deploys your portfolio website to AWS using S3, CloudFront, and ACM for a secure, fast, and cost-effective hosting solution.

## 🏗️ Architecture

- **S3 Bucket**: Stores website files (private, accessible only via CloudFront)
- **CloudFront**: CDN for fast global delivery and HTTPS termination
- **ACM Certificate**: Free SSL/TLS certificate for HTTPS
- **Route53**: DNS management (optional - can use GoDaddy DNS)

## 💰 Cost Optimization

- **S3**: ~$0.023 per GB/month (very low for static websites)
- **CloudFront**: PriceClass_100 (North America + Europe only) - ~$0.085 per GB
- **ACM**: Free SSL certificates
- **Route53**: $0.50/month per hosted zone (optional)

**Estimated monthly cost: < $1 for typical portfolio websites**

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** installed and configured with appropriate permissions
2. **Terraform** installed (version >= 1.0)
3. **Domain** purchased on GoDaddy (secada.in)
4. **AWS Account** with appropriate permissions

### Required AWS Permissions

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:PutBucketPolicy",
                "s3:PutBucketVersioning",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "cloudfront:CreateDistribution",
                "cloudfront:UpdateDistribution",
                "cloudfront:DeleteDistribution",
                "cloudfront:CreateInvalidation",
                "cloudfront:GetDistribution",
                "acm:RequestCertificate",
                "acm:DeleteCertificate",
                "acm:DescribeCertificate",
                "route53:CreateHostedZone",
                "route53:DeleteHostedZone",
                "route53:CreateRecordSet",
                "route53:DeleteRecordSet",
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": "*"
        }
    ]
}
```

### Step 1: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (us-east-1)
# Enter your output format (json)
```

### Step 2: Initialize Terraform

```bash
cd terraform
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

### Step 4: Apply the Infrastructure

```bash
terraform apply
```

**Important**: When prompted, type `yes` to confirm.

### Step 5: Deploy Website Files

```bash
cd ../scripts
chmod +x deploy.sh
./deploy.sh
```

### Step 6: Configure DNS in GoDaddy

1. Log into your GoDaddy account
2. Go to DNS Management for secada.in
3. Create a new A record:
   - **Name**: abhishek
   - **Value**: [CloudFront Distribution Domain] (from terraform output)
   - **TTL**: 600 (10 minutes)

## 🔧 Configuration

### Variables

Edit `terraform.tfvars` to customize your deployment:

```hcl
aws_region = "us-east-1"
bucket_name = "abhishek-portfolio-website"
domain_name = "abhishek.secada.in"
route53_zone_id = ""  # Leave empty for GoDaddy DNS
environment = "production"
enable_cloudfront_logging = false
cloudfront_price_class = "PriceClass_100"
```

### Customization Options

- **CloudFront Price Class**: Choose from `PriceClass_100` (NA+EU), `PriceClass_200` (NA+EU+Asia), or `PriceClass_All` (Global)
- **Caching**: Adjust TTL values in `main.tf` for different file types
- **Security**: Enable CloudFront logging for monitoring (adds minimal cost)

## 📁 File Structure

```
.
├── terraform/             # Terraform configuration files
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Variable definitions
│   ├── locals.tf         # Local variables and configuration
│   ├── billing-api.tf    # Billing API infrastructure
│   ├── cloudflare.tf     # Cloudflare configuration
│   └── terraform.tfvars  # Variable values
├── src/                  # Source files
│   ├── index.html        # Your portfolio website
│   ├── config.json       # Configuration file
│   ├── aws-billing-api.js # AWS Lambda function
│   └── generate-config.js # Config generation script
├── scripts/              # Deployment and setup scripts
│   ├── deploy.sh         # Main deployment script
│   ├── deploy-billing-api.sh # Billing API deployment
│   ├── setup-cloudflare.sh   # Cloudflare setup
│   └── deploy.bat        # Windows deployment script
├── docs/                 # Documentation
│   ├── README.md         # This file
│   ├── CONFIGURATION.md  # Configuration guide
│   ├── CLOUDFLARE_SETUP.md # Cloudflare setup guide
│   ├── GODADDY_DNS_SETUP.md # DNS setup guide
│   └── COST_ESTIMATION.md # Cost estimation guide
├── assets/               # Website assets (images, CSS, JS)
│   ├── images/           # Images and certificates
│   ├── js/               # JavaScript files
│   └── Abhishek_Gupta_Resume.pdf # Resume
├── deployments/          # Deployment artifacts
│   └── *.zip            # Deployment packages
└── README.md            # Main project README
```

## 🔒 Security Features

- **S3 Bucket**: Private with no public access
- **CloudFront**: Origin Access Control (OAC) for secure S3 access
- **HTTPS**: TLS 1.2+ enforced
- **CORS**: Configured for web security
- **IAM**: Least privilege access policies

## 📊 Monitoring & Maintenance

### CloudFront Metrics
- Monitor data transfer and request counts
- Set up CloudWatch alarms for high costs
- Use CloudFront analytics for performance insights

### S3 Monitoring
- Enable S3 access logging (optional)
- Monitor bucket size and object counts
- Set up lifecycle policies for cost optimization

### Cost Monitoring
- Use AWS Cost Explorer to track expenses
- Set up billing alerts
- Monitor CloudFront data transfer costs

## 🚨 Troubleshooting

### Common Issues

1. **ACM Certificate Validation Failed**
   - Check DNS records are correctly configured
   - Ensure domain ownership verification

2. **CloudFront Distribution Not Working**
   - Verify S3 bucket policy allows CloudFront access
   - Check CloudFront distribution status

3. **DNS Not Resolving**
   - Verify GoDaddy DNS settings
   - Wait for DNS propagation (up to 48 hours)
   - Check Route53 hosted zone configuration

4. **S3 Upload Errors**
   - Verify AWS credentials and permissions
   - Check S3 bucket exists and is accessible

### Useful Commands

```bash
# Check Terraform state
terraform show

# List S3 bucket contents
aws s3 ls s3://[bucket-name]

# Check CloudFront distribution
aws cloudfront get-distribution --id [distribution-id]

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id [id] --paths "/*"

# Check ACM certificate status
aws acm describe-certificate --certificate-arn [arn]
```

## 🗑️ Cleanup

To remove all resources and avoid charges:

```bash
terraform destroy
```

**Warning**: This will delete all created resources including your website!

## 📚 Additional Resources

- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [ACM User Guide](https://docs.aws.amazon.com/acm/latest/userguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review AWS CloudTrail logs for API errors
3. Verify Terraform state with `terraform show`
4. Check AWS service quotas and limits

## 📝 License

This configuration is provided as-is for educational and deployment purposes. 