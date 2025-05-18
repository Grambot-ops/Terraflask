resource "aws_lb" "app_alb" {
  name               = "${local.project_tag}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  enable_deletion_protection = false # Set to true in production
  tags               = local.tags
}

resource "aws_lb_target_group" "app_tg" {
  name_prefix  = "fctg-"
  port         = 5000
  protocol     = "HTTP"
  vpc_id       = aws_vpc.main.id
  target_type  = "ip"
  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.http_port # Keep as HTTP
  protocol          = "HTTP"     # Keep as HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Optional: Add HTTPS listener later if needed and certificate is available
# resource "aws_lb_listener" "frontend_https" {
#   count = var.enable_https ? 1 : 0

#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = var.https_port
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08" 
#   certificate_arn   = var.acm_certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }
