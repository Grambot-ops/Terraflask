# resource "aws_iam_role" "ecs_task_execution_role" {
#   name = "${local.project_tag}-ecs-task-execution-role"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
#   tags = local.tags
# }

# resource "aws_iam_policy" "ecs_task_execution_policy" {
#   name   = "${local.project_tag}-ecs-task-execution-policy"
#   policy = data.aws_iam_policy_document.ecs_task_execution_permissions.json
#   tags   = local.tags
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
# }
