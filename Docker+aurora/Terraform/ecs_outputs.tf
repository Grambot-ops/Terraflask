output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value = aws_ecr_repository
}

output "ecs_service_name" {
  description = "Name of the ECS service running the application"
  value = aws_ecs_services.main.name
}