# ecs_outputs.tf
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name 
}
output "ecs_service_name" {
  description = "Name of the ECS service running the application"
  value       = aws_ecs_service.app.name 
}