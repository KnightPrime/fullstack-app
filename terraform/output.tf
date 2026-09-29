output "app_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Public IP address of the server"
}

