@echo off
REM Portfolio Website Deployment Script for Windows
REM This script deploys the website to S3 after Terraform creates the infrastructure

echo 🚀 Starting Portfolio Website Deployment...

REM Check if AWS CLI is installed
where aws >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] AWS CLI is not installed. Please install it first.
    pause
    exit /b 1
)

REM Check if Terraform is installed
where terraform >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Terraform is not installed. Please install it first.
    pause
    exit /b 1
)

REM Check if required files exist
if not exist "..\src\index.html" (
    echo [ERROR] index.html not found in src directory
    pause
    exit /b 1
)

if not exist "..\assets" (
    echo [WARNING] assets directory not found. Only index.html will be deployed.
)

REM Check if we're in the right directory
if not exist "..\terraform\main.tf" (
    echo [ERROR] main.tf not found. Please run this script from the scripts directory.
    pause
    exit /b 1
)

REM Check if Terraform has been initialized
if not exist "..\terraform\.terraform" (
    echo [INFO] Terraform not initialized. Running 'terraform init'...
    cd ..\terraform
    terraform init
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to initialize Terraform
        pause
        exit /b 1
    )
    echo [SUCCESS] Terraform initialized successfully!
    cd ..\scripts
)

REM Check if Terraform plan exists or if we need to apply
if not exist "..\terraform\terraform.tfstate" (
    echo [WARNING] No Terraform state found. You need to run 'terraform apply' first to create the infrastructure.
    echo.
    echo Please run the following commands:
    echo    cd ..\terraform
    echo    terraform plan
    echo    terraform apply
    echo.
    echo Then run this deployment script again.
    pause
    exit /b 1
)

echo [INFO] Getting infrastructure details from Terraform...

REM Get S3 bucket name from Terraform output
for /f "tokens=*" %%i in ('cd ..\terraform ^& terraform output -raw website_bucket_name 2^>nul') do set BUCKET_NAME=%%i

if "%BUCKET_NAME%"=="" (
    echo [ERROR] Could not get S3 bucket name from Terraform output. Make sure to run 'terraform apply' first.
    pause
    exit /b 1
)

REM Get CloudFront distribution ID from Terraform output
for /f "tokens=*" %%i in ('cd ..\terraform ^& terraform output -raw cloudfront_distribution_id 2^>nul') do set CLOUDFRONT_ID=%%i

if "%CLOUDFRONT_ID%"=="" (
    echo [ERROR] Could not get CloudFront distribution ID from Terraform output.
    pause
    exit /b 1
)

echo [SUCCESS] S3 Bucket: %BUCKET_NAME%
echo [SUCCESS] CloudFront Distribution: %CLOUDFRONT_ID%

echo [INFO] Syncing website files to S3...

REM Create a temporary directory for deployment
set TEMP_DIR=%TEMP%\portfolio-deploy-%RANDOM%
mkdir "%TEMP_DIR%"

REM Copy files to temp directory maintaining structure
copy "..\src\index.html" "%TEMP_DIR%\"
if exist "..\assets" (
    xcopy "..\assets" "%TEMP_DIR%\assets\" /E /I /Y
)

REM Sync files from temp directory to S3 bucket
aws s3 sync "%TEMP_DIR%" "s3://%BUCKET_NAME%" ^
    --delete ^
    --cache-control "max-age=31536000" ^
    --metadata-directive REPLACE

if %errorlevel% neq 0 (
    echo [ERROR] Failed to upload website files to S3
    rmdir /s /q "%TEMP_DIR%"
    pause
    exit /b 1
)

REM Clean up temp directory
rmdir /s /q "%TEMP_DIR%"

echo [SUCCESS] Website files uploaded to S3 successfully!

REM Set proper content types for HTML files
echo [INFO] Setting proper content types...
aws s3 cp "s3://%BUCKET_NAME%/index.html" "s3://%BUCKET_NAME%/index.html" ^
    --content-type "text/html" ^
    --cache-control "no-cache" ^
    --metadata-directive REPLACE

REM Set content types for CSS and JS files if they exist
if exist "..\assets" (
    echo [INFO] Setting content types for assets...
    
    REM Find and set content types for CSS files
    for /r "..\assets" %%f in (*.css) do (
        aws s3 cp "s3://%BUCKET_NAME%/%%f" "s3://%BUCKET_NAME%/%%f" ^
            --content-type "text/css" ^
            --cache-control "max-age=31536000" ^
            --metadata-directive REPLACE
    )
    
    REM Find and set content types for JS files
    for /r "..\assets" %%f in (*.js) do (
        aws s3 cp "s3://%BUCKET_NAME%/%%f" "s3://%BUCKET_NAME%/%%f" ^
            --content-type "application/javascript" ^
            --cache-control "max-age=31536000" ^
            --metadata-directive REPLACE
    )
)

echo [SUCCESS] Content types set successfully!

REM Invalidate CloudFront cache
echo [INFO] Invalidating CloudFront cache...
aws cloudfront create-invalidation --distribution-id "%CLOUDFRONT_ID%" --paths "/*" >nul 2>&1

if %errorlevel% equ 0 (
    echo [SUCCESS] CloudFront cache invalidation initiated!
    echo [INFO] Cache invalidation may take 5-10 minutes to complete.
) else (
    echo [WARNING] Failed to invalidate CloudFront cache. You may need to do this manually.
)

REM Get website URL
for /f "tokens=*" %%i in ('cd ..\terraform ^& terraform output -raw website_url 2^>nul') do set WEBSITE_URL=%%i

if "%WEBSITE_URL%"=="" (
    set WEBSITE_URL=https://%BUCKET_NAME%.s3.amazonaws.com
)

echo [SUCCESS] 🎉 Website deployment completed successfully!
echo.
echo 📱 Your website is now available at:
echo    %WEBSITE_URL%
echo.
echo 🔧 Next steps:
echo    1. Wait for CloudFront cache invalidation (5-10 minutes)
echo    2. Update your GoDaddy DNS settings:
echo       - Create an A record for 'abhishek.secada.in'
echo       - Point it to: %CLOUDFRONT_ID%
echo    3. Wait for DNS propagation (up to 48 hours)
echo.
echo 📊 To monitor your deployment:
echo    - CloudFront Distribution: %CLOUDFRONT_ID%
echo    - S3 Bucket: %BUCKET_NAME%
echo.
echo [SUCCESS] Deployment script completed!
pause 