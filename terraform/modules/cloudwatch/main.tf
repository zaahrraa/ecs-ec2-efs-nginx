resource "aws_cloudwatch_log_group" "ecs_nginx" {
  name = "/ecs/${var.project_name}-nginx"
}