terraform {
  backend "s3" {
    bucket            = "rmit-tfstate-3sirfd"
    key               = "assignment-2/infra-deployment"
    region            = "us-east-1"
    dynamodb_table    = "rmit-locktable-3sirfd"
    dynamodb_endpoint = "https://dynamodb.us-east-1.amazonaws.com"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
