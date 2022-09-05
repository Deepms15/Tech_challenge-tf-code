
module "log" {
    source = "../cloudwatch"

    app_name     = var.name
    log_group    = var.ecs_config[0].service.log_group
    retention    = var.ecs_config[0].service.log_retention

    common_tags  = var.common_tags
}

# module "ecs_role" {
#     source = "../ecs_role"

#     role_name    = var.ecs_config[0].task_definition.execution_role
#     common_tags  = var.common_tags
# }

data "aws_iam_role" "ecsTaskExecutionRole" {
    name = var.ecs_config[0].task_definition.execution_role
}

module "ecs_cluster" {
    source          = "../ecs_cluster"

    name            = var.name
    common_tags     = var.common_tags
}


module "ecs_task" {
    source            = "../ecs_task"

    cluster_id        = module.ecs_cluster.id
    name              = var.name
    subnets           = var.ecs_subnets
    security_groups   = var.ecs_security_groups
    #target_group_arn= var.target_group_arn
    target_group_arns = var.target_group_arns
    template_file     = var.ecs_config[0].template
    task_definition   = var.ecs_config[0].task_definition
    service           = var.ecs_config[0].service
    environment       = var.environment
    #exec_role_arn   = module.ecs_role.arn
    exec_role_arn      = data.aws_iam_role.ecsTaskExecutionRole.arn

    common_tags        = var.common_tags
}

