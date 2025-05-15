output "rds_cluster_endpoint" {
  description = "Writer endpoint of the RDS Aurora cluster"
  value = aws_rds_cluster.main.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Reader endpoint of the RDS aurora cluster (need to run multiple instances)"
  value = aws_rds_cluster.main.rds_cluster_reader_endpoint
}

output "rds_cluster_port" {
  description = "Port of the RDS Aurora cluster"
  value = aws_rds_cluster.main.Port
}

output "database_name_output" {
  description = "Name of the database Created in Aurora"
  value = var.db_name
}

output "database_master_username_output" {
  description = "Master username for the aurora database"
  value = var.db_username
}