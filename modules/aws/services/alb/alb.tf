

resource "aws_lb" "alb" {
    name                = var.name
    #internal            = var.internal
    load_balancer_type  = "application"
    subnets             = var.subnets
    security_groups     = var.security_groups
    enable_deletion_protection = var.enable_deletion_protection 

    tags = merge(
        {
            Name=var.name, 
        },
        var.common_tags,
    )
}

resource "aws_alb_target_group" "app" {
    name        = "tg-${var.name}"
    port        = var.port
    protocol    = var.protocol
    vpc_id      = var.vpc_id
    target_type = var.target_type

    health_check {
        healthy_threshold   = var.health_check_map.healthy_threshold
        interval            = var.health_check_map.interval
        protocol            = var.health_check_map.protocol
        matcher             = var.health_check_map.matcher
        timeout             = var.health_check_map.timeout
        path                = var.health_check_map.path
        unhealthy_threshold = var.health_check_map.unhealthy_threshold
    }

    tags = merge(
        {
            Name="tg-${var.name}", 
        },
        var.common_tags,
    )    

    depends_on = ["aws_lb.alb",]    
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.alb.id
    port              = var.listener_app_port
    protocol          = var.listener_app_protocol

    default_action {
        target_group_arn = aws_alb_target_group.app.id
        type             = var.action_type
    }  

    depends_on = ["aws_lb.alb","aws_alb_target_group.app"]   
}