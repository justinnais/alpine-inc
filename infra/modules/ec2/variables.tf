variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "vpc_id" {
  type = string
}

variable "private_az1_subnet_id" {
  type = string
}

variable "data_az1_subnet_id" {
  type = string
}