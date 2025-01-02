terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = var.region
}


# Lambda Function
resource "aws_lambda_function" "hello_world" {
  filename      = "./build/lambda.zip"
  function_name = "hello-world-function"
  # role          = "arn:aws:iam::303441323650:role/service-role/qa_lambda_function"
  role          = "arn:aws:iam::303441323650:role/lambda_basic_execution"
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  source_code_hash = filebase64sha256("./build/lambda.zip")
}
#
# # IAM Role for Lambda
# resource "aws_iam_role" "lambda_role" {
#   name = "hello-world-lambda-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
