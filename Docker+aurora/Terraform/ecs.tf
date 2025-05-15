resource "aws_ecs_cluster" "main" {
  name = "${local.project_tag}-ecs-cluster"
  tags = local.tags
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.project_tag}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn = "arn:aws:iam::125755581655:role/voclabs"

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.app_image_uri
      essential = true
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
  	  secrets = [{
        name = "DATABASE_URL"
        valueFrom = aws_ssm_parameter.db_url_ssm.arn
        
      },
      {
        name = "SECRET_KEY"
        valueFrom = aws_secretsmanager_secret.flask_secret.arn
      }
      ]
      environment = [
        {name = "FLASK_ENV", value = "production"},
        {name = "PYTHONUNBUFFERED", value = "1"}
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_service_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${local.project_tag}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "app"
    container_port   = 5000
  }
  depends_on = [aws_lb_listener.frontend_http]
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_service_logs" {
  name              = "/ecs/${local.project_tag}-app" # Use -app or similar differentiator
  retention_in_days = 7
  tags              = local.tags
}
