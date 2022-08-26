terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
  }
  backend "s3" {
    bucket            = "rmit-tfstate-g0dz82"
    key               = "assignment-2/infra-deployment"
    region            = "us-east-1"
    dynamodb_table    = "rmit-locktable-g0dz82"
    dynamodb_endpoint = "https://dynamodb.us-east-1.amazonaws.com"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source                = "./modules/ec2"
  vpc_id                = module.vpc.vpc_id
  private_az1_subnet_id = module.vpc.private_az1_subnet_id
  data_az1_subnet_id    = module.vpc.data_az1_subnet_id
}