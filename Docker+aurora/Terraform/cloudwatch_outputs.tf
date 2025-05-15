output "cloudwatch_log_group_ecs" {
  description = "CloudWatch log group for ECS application logs"
  value = aws_cloudwatch_log_group.ecs_service_logs.name
}