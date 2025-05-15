locals {
  project_tag = var.project_name
  tags = {
    project = local.project_tag
    Terraform = "true"
  }
  db_port = 5432

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}