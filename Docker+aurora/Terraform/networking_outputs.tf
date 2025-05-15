output "security_group_ids_map" {
  description = "Map of created security groups (Name -> ID)."
  value = {
    alb         = aws_security_group.alb.id
    ecs_service = aws_security_group.ecs_service.id
    db_aurora   = aws_security_group.db_aurora.id
  }
}

output "route_table_ids_map" {
  description = "Map of created route tables (Name -> ID)."
  value = {
    public      = aws_route_table.public.id
    private_az0 = var.az_count > 0 ? aws_route_table.private[0].id : "N/A"
    private_az1 = var.az_count > 1 ? aws_route_table.private[1].id : "N/A"
  }
}
