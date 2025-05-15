variable "app_image_uri" {
  description = "Required: Full ECR URI for the flask app image"
  type = string
}

variable "app_container_port" {
  description = "Port the application container listens on"
  type = number
  default = 5000
}

variable "app_cpu" {
  description = "cpu units for ECS Fargate task"
  type = number
  default = 512
}

variable "app_memory" {
  description = "Memory in Mib for ECS Fargete task"
  type = number
  default = 1024
}

variable "app_desired_count" {
  description = "Desired nubmer of application tasks"
  type = number
  default = 1
}