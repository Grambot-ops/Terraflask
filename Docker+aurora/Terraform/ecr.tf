resource "aws_ecr_repository" "app_repo" {
  name                 = "${local.project_tag}-app"
  image_tag_mutability = "MUTABLE"
  tags                 = local.tags
}
