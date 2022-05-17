output "vpc_id" {
  description = "ID of the VPC"
  value = aws_vpc.main.id
}

output "private_az1_subnet_id" {
  description = "ID of the private subnet in AZ 1"
  value = aws_subnet.private_subnet[0].id
}

output "data_az1_subnet_id" {
  description = "ID of the data subnet in AZ 1"
  value = aws_subnet.data_subnet[0].id
}