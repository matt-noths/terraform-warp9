terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}


# Lambda Function
resource "aws_lambda_function" "hello_world" {
  filename      = "lambda.zip"
  function_name = "hello-world-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  source_code_hash = filebase64sha256("./build/lambda.zip")
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "hello-world-lambda-role"

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

# IAM Policy for Lambda to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

# API Gateway
resource "aws_api_gateway_rest_api" "hello_world_api" {
  name = "hello-world-api"
}

resource "aws_api_gateway_resource" "hello_world_resource" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  parent_id   = aws_api_gateway_rest_api.hello_world_api.root_resource_id
  path_part   = "hello-world"
}

resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id
  resource_id   = aws_api_gateway_resource.hello_world_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id             = aws_api_gateway_rest_api.hello_world_api.id
  resource_id             = aws_api_gateway_resource.hello_world_resource.id
  http_method             = aws_api_gateway_method.hello_world_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn
}

# DynamoDB Table
resource "aws_dynamodb_table" "hello_world_counter" {
  name         = "HelloWorldCounter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# S3 Bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = "hello-world-counter-website"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}
