# GoDaddy DNS Setup Guide (When Nameservers Can't Be Changed)

This guide helps you set up your portfolio website when GoDaddy prevents external nameserver changes.

## 🚨 **Problem: GoDaddy Nameserver Restriction**

**Error**: `DNSZoneExternalNameserver`
**Issue**: GoDaddy is preventing you from using Cloudflare nameservers

## 🔧 **Solution: Use GoDaddy DNS with CNAME**

Since you can't change nameservers, we'll use GoDaddy's DNS management with a CNAME record.

### **Step 1: Add CNAME Record in GoDaddy**

1. **Log into GoDaddy**
2. **Go to DNS Management** for `secada.in`
3. **Click "Add"** in the DNS Records section
4. **Add CNAME Record**:
   ```
   Type: CNAME
   Name: abhishek
   Value: d37bdiw604950r.cloudfront.net
   TTL: 600 (10 minutes)
   ```
5. **Save the record**

### **Step 2: Verify DNS Record**

After adding the CNAME record, test it:

```bash
# Check if the CNAME record is working
dig abhishek.secada.in CNAME

# Or use nslookup
nslookup abhishek.secada.in
```

### **Step 3: Deploy Terraform (Limited Cloudflare Features)**

Since we can't use Cloudflare nameservers, we'll deploy with limited Cloudflare features:

```bash
# Deploy the infrastructure
terraform plan
terraform apply
```

## 🛡️ **What You'll Get (Limited Cloudflare Features)**

### ✅ **Available Features:**
- **AWS CloudFront**: Full CDN functionality
- **SSL/TLS**: HTTPS encryption
- **Performance**: Fast global delivery
- **Security**: Basic AWS security

### ❌ **Not Available (Requires Cloudflare Nameservers):**
- **Cloudflare WAF**: Web Application Firewall
- **Cloudflare DDoS Protection**: Advanced DDoS mitigation
- **Cloudflare Rate Limiting**: Request rate limiting
- **Cloudflare Analytics**: Security and performance analytics

## 🌐 **Alternative Security Options**

### **Option 1: AWS WAF (Recommended)**
Since Cloudflare WAF isn't available, we can use AWS WAF:

```bash
# Deploy AWS WAF instead
# (We can add this later if needed)
```

### **Option 2: Contact GoDaddy Support**
Try to get nameserver changes enabled:

1. **Call GoDaddy**: 1-866-938-1119
2. **Request**: "Enable external nameserver changes for my domain"
3. **They may**: Enable it for your account

### **Option 3: Transfer Domain**
Consider transferring to a registrar that allows external nameservers:
- **Namecheap**: Allows external nameservers
- **Cloudflare Registrar**: Free, full Cloudflare integration
- **Google Domains**: Allows external nameservers

## 📋 **Current Setup Summary**

### **DNS Configuration:**
```
abhishek.secada.in → CNAME → d37bdiw604950r.cloudfront.net
```

### **Traffic Flow:**
```
User Request
    ↓
GoDaddy DNS (CNAME lookup)
    ↓
CloudFront Distribution
    ↓
S3 Bucket (Website Files)
```

### **Security:**
- ✅ **HTTPS**: SSL/TLS encryption
- ✅ **CloudFront**: Basic security features
- ❌ **WAF**: No advanced web application firewall
- ❌ **DDoS Protection**: Limited to CloudFront protection

## 🔄 **Future Upgrade Path**

If you want full Cloudflare features later:

1. **Contact GoDaddy Support** to enable nameservers
2. **Or transfer domain** to Cloudflare Registrar (free)
3. **Then uncomment** Cloudflare resources in `cloudflare.tf`
4. **Redeploy** with full Cloudflare features

## ✅ **Next Steps**

1. **Add CNAME record** in GoDaddy DNS
2. **Test DNS resolution**: `dig abhishek.secada.in`
3. **Deploy infrastructure**: `terraform apply`
4. **Test website**: Visit `https://abhishek.secada.in`

Your website will work perfectly with CloudFront CDN, just without the advanced Cloudflare security features!
