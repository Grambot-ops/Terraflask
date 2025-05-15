output "database_url_ssm_parameter_name" {
  description = "Name of the SSM Parameter storing the full database connection url (database url) "
  value = aws_ssm_parameter.db_url_ssm.name
}