

data "template_file" "app" {

  template = file(var.template_file)

  vars = {
    app_name       = "${var.name}-app"
    task_name      = "${var.name}-task"
    app_image      = var.service.image
    app_port       = var.service.port
    fargate_cpu    = var.task_definition.cpu
    fargate_memory = var.task_definition.memory
    aws_region     = "ap-southeast-1"
    log_group      = var.service.log_group
    logs_stream_pfx= var.service.logs_stream_pfx
    #environment    = var.environment
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-task"
  execution_role_arn       = var.exec_role_arn
  network_mode             = var.task_definition.network_mode
  requires_compatibilities = [var.task_definition.compatibilities]
  cpu                      = var.task_definition.cpu
  memory                   = var.task_definition.memory
  container_definitions    = data.template_file.app.rendered 

  volume {name = var.volume_name}

  tags = merge(
      {
          Name="${var.name}-task", 
      },
      var.common_tags,
  )  
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.service.desired_count
  launch_type     = var.service.launch_type

  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.subnets
    assign_public_ip = var.service.assign_public_ip
  }

  # load_balancer {
  #   target_group_arn = var.target_group_arn
  #   container_name   = "${var.name}-app"
  #   container_port   = var.service.port
  #   }


  dynamic "load_balancer" {
    iterator = arn
    for_each = var.target_group_arns
    content {
      target_group_arn = arn.value[0]
      container_name   = "${var.name}-app"
      container_port   = arn.value[1]
    }
  }  

  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  #The new ARN and resource ID format must be enabled to add tags to the service. Opt in to the new format and try again.
  # tags = merge(
  #     {
  #         Name="${var.name}-service", 
  #     },
  #     var.common_tags,
  # ) 
}


#Autoscaling------------------------------------------------------------

data "aws_iam_role" "ecsAutoScalingRole" {
    count = var.service.autoscale == "true" ? 1 : 0

    name = var.service.autoScalingRole
}

resource "aws_appautoscaling_target" "this" {
    count = var.service.autoscale == "true" ? 1 : 0

    max_capacity       = var.service.max_count
    min_capacity       = var.service.desired_count
    resource_id        = "service/${var.name}-cluster/${var.name}-service"
    role_arn           = data.aws_iam_role.ecsAutoScalingRole[0].arn
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"

    depends_on = [aws_ecs_service.main]
}

resource "aws_appautoscaling_policy" "this" {
  count = var.service.autoscale == "true" ? 1 : 0

  name               = "${var.name}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.service.max_cpu_util 

    scale_in_cooldown  = var.service.scale_in_cooldown 
    scale_out_cooldown = var.service.scale_out_cooldown 

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.this]
}