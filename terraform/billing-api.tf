# AWS Billing API Lambda Function
resource "aws_lambda_function" "billing_api" {
  filename         = "aws-billing-api.zip"
  function_name    = local.billing_api_function_name
  role            = aws_iam_role.billing_api_role.arn
  handler         = "aws-billing-api.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }

  tags = {
    Name = "Portfolio Billing API"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "billing_api_role" {
  name = local.billing_api_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Cost Explorer access
resource "aws_iam_role_policy" "billing_api_policy" {
  name = local.billing_api_policy_name
  role = aws_iam_role.billing_api_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetDimensionValues",
          "ce:GetReservationUtilization",
          "ce:GetReservationCoverage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "billing_api" {
  name = local.billing_api_function_name
  description = "API for AWS billing data"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "billing_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.billing_api.id
  parent_id   = aws_api_gateway_rest_api.billing_api.root_resource_id
  path_part   = "billing"
}

# API Gateway Method
resource "aws_api_gateway_method" "billing_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.billing_api.id
  resource_id   = aws_api_gateway_resource.billing_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "billing_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.billing_api.id
  resource_id = aws_api_gateway_resource.billing_api_resource.id
  http_method = aws_api_gateway_method.billing_api_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.billing_api.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "billing_api_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.billing_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.billing_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "billing_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.billing_api_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.billing_api.id
  stage_name  = "prod"
}

# Output the API URL
output "billing_api_url" {
  description = "URL of the billing API"
  value       = "${aws_api_gateway_deployment.billing_api_deployment.invoke_url}/billing"
} 