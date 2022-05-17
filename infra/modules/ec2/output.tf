output "web_public_ip" {
  description = "Public IP Address of the web instance"
  value = aws_instance.web.public_ip
}

output "db_public_ip" {
  description = "Public IP Address of the database instance"
  value = aws_instance.db.public_ip
}