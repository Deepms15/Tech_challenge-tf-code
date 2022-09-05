


output "definition" {
    value = aws_ecs_task_definition.app.id
}

output "service" {
    value = aws_ecs_service.main.id
}