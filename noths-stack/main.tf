terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# module "env" {
#   source  = "app.terraform.io/notonthehighstreet/noths-env-vars/module"
#   version = "~> 1.5"
# }
