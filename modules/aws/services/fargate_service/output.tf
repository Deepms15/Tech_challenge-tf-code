

# output "alb" {
#     value = module.alb
# }

output "ecs" {
    value = {
        "cluster"         : module.ecs_cluster.id
        "task_definition" : module.ecs_task.definition
        "service"         : module.ecs_task.service
    }
}

