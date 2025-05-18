resource "random_password" "flask_secret_key_gen" {
  length  = 32
  special = false # Flask secret keys are often simpler strings
}

resource "aws_secretsmanager_secret" "flask_secret" {
  name = "${local.project_tag}/flask-secret-key-v2"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "flask_secret" {
  secret_id     = aws_secretsmanager_secret.flask_secret.id
  secret_string = random_password.flask_secret_key_gen.result
}