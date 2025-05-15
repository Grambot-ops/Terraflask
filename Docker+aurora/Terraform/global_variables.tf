variable "aws_region" {
  description = "AWS region for deployment"
  type = string
  default = "us-east-1"
}

variable "project_name" {
  description = "Unique name for the project to use in prefix resources"
  type = string
  default = "flask-crud-r0984339"
}

variable "az_count" {
  description = "Number of availability Zones to use (minimum 2 for HA) but for test we will do 1"
  type = number
  default = 2
}