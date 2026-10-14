output "public_ip" {
  description = "Public Elastic IP assigned to the EC2 server"
  value       = aws_eip.app_eip.public_ip
}

output "frontend_url" {
  description = "Next.js Frontend Web Application"
  value       = "http://${aws_eip.app_eip.public_ip}:3000"
}

output "backend_api_url" {
  description = "FastAPI Backend REST API"
  value       = "http://${aws_eip.app_eip.public_ip}:8000"
}

output "backend_docs_url" {
  description = "FastAPI Interactive Swagger API Documentation"
  value       = "http://${aws_eip.app_eip.public_ip}:8000/docs"
}

output "prometheus_url" {
  description = "Prometheus Metrics Server Web UI"
  value       = "http://${aws_eip.app_eip.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana Observability Dashboard"
  value       = "http://${aws_eip.app_eip.public_ip}:3001"
}

output "grafana_credentials" {
  description = "Default Grafana login credentials"
  value       = "Username: admin | Password: admin"
}

output "ssh_command" {
  description = "Command to SSH into the EC2 instance (if key_name was supplied)"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_eip.app_eip.public_ip}"
}
