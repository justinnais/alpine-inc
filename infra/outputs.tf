output "web_public_ip" {
  description = "Public IP Address of the web instance"
  value       = module.ec2.web_public_ip
}

output "db_public_ip" {
  description = "Public IP Address of the database instance"
  value       = module.ec2.db_public_ip
}