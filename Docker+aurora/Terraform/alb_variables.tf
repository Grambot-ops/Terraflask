variable "health_check_path" {
  description = "Path for ALB health checks"
  type        = string
  default     = "/health"
}

variable "enable_https" {
  description = "Enable HTTPS listener on ALB"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
  default     = ""
}

variable "http_port" {
  description = "Port for HTTP listener on ALB"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port for HTTPS listener on ALB"
  type        = number
  default     = 443
}
