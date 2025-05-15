resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_-"
}

resource "aws_secretsmanager_secret" "db_master_password" {
  name = "${local.project_tag}/db-master-password"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db_master_password" {
  secret_id     = aws_secretsmanager_secret.db_master_password.id
  secret_string = random_password.db_password.result
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${local.project_tag}-aurora-sng"
  subnet_ids = aws_subnet.private[*].id
  tags = merge(local.tags, {
    Name = "${local.project_tag}-aurora-sng"
  })
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${local.project_tag}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = var.db_engine_version
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = random_password.db_password.result
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [aws_security_group.db_aurora.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  storage_encrypted       = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  tags = merge(local.tags, { Name = "${local.project_tag}-aurora-cluster", Tier = "database" })
}

resource "aws_rds_cluster_instance" "main" {
  count              = var.db_instance_count
  identifier         = "${local.project_tag}-aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  publicly_accessible = false
  tags = merge(local.tags, { Name = "${local.project_tag}-aurora-instance-${count.index}", Tier = "database" })
}
