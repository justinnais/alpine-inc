variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
  type = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  default = "RMIT Assignment 2"
  type = string
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type    = list(string)
}