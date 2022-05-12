variable "aws-linux-2-ami" {
  default = "ami-0022f774911c1d690"
  type    = string
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type    = list(string)
}