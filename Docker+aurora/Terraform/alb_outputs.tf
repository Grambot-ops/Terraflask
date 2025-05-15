output "alb_dns_name" {
description = "Public Dns name for the Application load balancer. You can access the application though this value"
value = aws_lb.app_alb.dns_name
}

output "alb_http_url" {
  description = "HTTP url to access the application (if user uses http)"
  value = "http://${aws_lb.app_alb.dns_name}"
}

output "alb_https_url" {
  description = "HTTPS URL to access the application (most users will have https enable, just to make sure)."
  value       = var.enable_https ? "https://${aws_lb.app_alb.dns_name}" : "HTTPS not enabled."
}