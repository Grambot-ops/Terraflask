resource "aws_ssm_parameter" "db_url_ssm" {
  name  = "/${local.project_tag}/DATABASE_URL" # Use a path-based name
  type  = "SecureString"                         # Encrypts with default KMS key for SSM
  value = "postgresql://${var.db_username}:${random_password.db_password.result}@${aws_rds_cluster.main.endpoint}:${aws_rds_cluster.main.port}/${var.db_name}"
  tags  = local.tags

  # Ensure this depends on the RDS cluster and the password random resource
  depends_on = [
    aws_rds_cluster.main,
    random_password.db_password
  ]
}