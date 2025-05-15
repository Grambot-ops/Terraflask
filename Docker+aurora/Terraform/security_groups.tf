resource "aws_security_group" "db_aurora" {
  name        = "${local.project_tag}-db-aurora-sg"
  description = "Allow PostgreSQL traffic from ECS Service"
  vpc_id      = aws_vpc.main.id
  tags = merge(local.tags, { Name = "${local.project_tag}-db-sg", Tier = "database" })
}

resource "aws_security_group" "ecs_service" {
  name        = "${local.project_tag}-ecs-service-sg"
  description = "Allow traffic from ALB to ECS tasks and allow outbound to DB and Internet (via NAT)"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.tags, { Name = "${local.project_tag}-ecs-sg", Tier = "application" })
}

resource "aws_security_group" "alb" {
  name        = "${local.project_tag}-alb-sg"
  description = "Allow HTTP/S traffic from internet to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.project_tag}-alb-sg", Tier = "frontend" })
}
