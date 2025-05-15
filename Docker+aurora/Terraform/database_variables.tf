variable "db_name" {
  description = "Database name for Aurora PostgreSQL"
  type = string
  default = "flaskCrudAppDb"
}

variable "db_username" {
  description = "Master username for Aurora DB"
  type = string
  default = "dbAdmin"
}

variable "db_engine_version" {
  description = "Aurora postgreSQL engine version"
  type = string
  default = "17"
}

variable "db_instance_class" {
  description = "Instance class for Aurora DB instance"
  type = string
  default = "db.t3.medium"
}

variable "db_instance_count" {
  description = "Number of DB instances in the Aurora cluster"
  type = number
  default = 1
}