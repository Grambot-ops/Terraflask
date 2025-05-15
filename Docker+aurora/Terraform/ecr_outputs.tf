output "ecs_outputs" {
  description = "URL of the ECR repository. This is where our Docker image is going to be pushed"
  value = aws_ecr_repository.app.repository_url
}