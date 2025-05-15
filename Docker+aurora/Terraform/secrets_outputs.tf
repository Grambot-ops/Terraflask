output "database_master_password_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the DB master passwords"
  value       = aws_secretsmanager_secret.db_master_password.arn
}

output "flask_secret_key_arn" {
  description = "ARN of the Secrets Manager secret storing the Flask Secret_key"
  value       = aws_secretsmanager_secret.flask_secret.arn
}