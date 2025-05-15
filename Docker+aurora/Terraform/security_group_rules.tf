resource "aws_security_group_rule" "allow_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_service.id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow ALB to ECS Service"
}

resource "aws_security_group_rule" "allow_ecs_to_db" {
  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_aurora.id
  source_security_group_id = aws_security_group.ecs_service.id
  description              = "Allow ECS tasks to access DB"
}

resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_service.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from ECS tasks"
}
