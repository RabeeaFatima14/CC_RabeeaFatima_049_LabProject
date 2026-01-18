# Frontend Outputs
output "frontend_public_ip" {
  description = "Public IP of frontend nginx server"
  value       = aws_instance.frontend.public_ip
}

output "frontend_private_ip" {
  description = "Private IP of frontend nginx server"
  value       = aws_instance.frontend.private_ip
}

# Backend Outputs
output "backend_public_ips" {
  description = "Public IPs of backend httpd servers"
  value       = [for instance in aws_instance.backend : instance.public_ip]
}

output "backend_private_ips" {
  description = "Private IPs of backend httpd servers"
  value       = [for instance in aws_instance.backend : instance.private_ip]
}

# All IPs for inventory generation
output "all_backend_info" {
  description = "All backend server information"
  value = [
    for idx, instance in aws_instance.backend : {
      name       = "backend-${idx + 1}"
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}

