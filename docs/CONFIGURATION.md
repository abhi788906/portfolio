# Centralized Configuration System

This project now uses a centralized configuration system to manage all repeating values across different file types.

## 📁 Configuration Files

### `config.json` - Main Configuration
This is the **single source of truth** for all configuration values in the project.

```json
{
  "project": {
    "name": "portfolio-website",
    "environment": "production",
    "region": "ap-south-1"
  },
  "aws": {
    "bucket_name": "abhishek-portfolio-website",
    "domain_name": "abhishek.secada.in",
    "billing_api": {
      "function_name": "portfolio-billing-api",
      "role_name": "portfolio-billing-api-role",
      "policy_name": "portfolio-billing-api-policy"
    },
    "terraform": {
      "state_bucket": "abhishek-portfolio-terraform-state",
      "state_key": "portfolio-website/terraform.tfstate",
      "lock_table": "terraform-state-lock"
    }
  },
  "contact": {
    "email": "abhi133182@outlook.com",
    "website": "https://abhishek.secada.in"
  },
  "cloudfront": {
    "price_class": "PriceClass_100",
    "enable_logging": false
  }
}
```

### `locals.tf` - Terraform Configuration
Reads from `config.json` and makes values available to all Terraform resources.

### `assets/js/config.js` - JavaScript Configuration
Auto-generated from `config.json` for use in frontend JavaScript.

### `assets/js/billing-config.js` - Billing API Configuration
Auto-generated configuration for the billing API.

## 🔄 How to Update Configuration

### 1. Edit `config.json`
Make your changes in the main configuration file:

```json
{
  "aws": {
    "bucket_name": "new-bucket-name"
  }
}
```

### 2. Regenerate JavaScript Configs
Run the configuration generator:

```bash
node generate-config.js
```

### 3. Apply Terraform Changes
Terraform will automatically pick up changes from `config.json`:

```bash
terraform plan
terraform apply
```

## 📋 Benefits

### ✅ **Single Source of Truth**
- All configuration in one place
- No more hunting for values across files
- Easy to maintain and update

### ✅ **Consistency**
- Same values used everywhere
- No risk of mismatched configuration
- Automatic validation

### ✅ **Environment Management**
- Easy to create different configs for dev/staging/prod
- Simple environment switching
- Version control friendly

### ✅ **Type Safety**
- JSON structure provides validation
- Clear documentation of all values
- IDE autocomplete support

## 🛠️ Usage Examples

### In Terraform
```hcl
# Use centralized values
resource "aws_s3_bucket" "website_bucket" {
  bucket = local.bucket_name
  tags   = local.common_tags
}
```

### In JavaScript
```javascript
// Use generated config
const bucketName = CONFIG.aws.bucket_name;
const contactEmail = CONFIG.contact.email;
```

### In HTML
```html
<!-- Use generated config -->
<script src="assets/js/config.js"></script>
<script>
  const websiteUrl = CONFIG.contact.website;
</script>
```

## 🔧 Adding New Configuration

1. **Add to `config.json`:**
```json
{
  "new_section": {
    "new_value": "example"
  }
}
```

2. **Add to `locals.tf`:**
```hcl
locals {
  new_value = local.config.new_section.new_value
}
```

3. **Regenerate JavaScript configs:**
```bash
node generate-config.js
```

## 📝 Migration Notes

- ✅ **Terraform**: All resources now use `local.*` values
- ✅ **JavaScript**: Generated configs available in `assets/js/`
- ✅ **HTML**: Can reference `CONFIG` object globally
- ⚠️ **Manual Updates**: Some files may still need manual updates for dynamic values

## 🚀 Next Steps

1. **Update HTML**: Replace hardcoded values with `CONFIG` references
2. **Environment Configs**: Create separate configs for different environments
3. **Validation**: Add JSON schema validation
4. **CI/CD**: Integrate config generation into deployment pipeline
