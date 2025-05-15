variable "vpc_cidr" {
  description = "CIDR block for the vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_offset" {
  description = "Offset for public subnet CIDR calculations"
  type = number
  default = 0
}

variable "private_subnet_offset" {
  description = "Offset for private subnet CIDR calculations"
  type = number
  default = 100
}