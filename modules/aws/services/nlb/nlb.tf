

resource "aws_lb" "this" {
    name                = var.name
    internal            = var.internal
    load_balancer_type  = "network"
    #subnets             = var.subnets
    security_groups     = var.security_groups
    enable_deletion_protection = var.enable_deletion_protection   
    enable_cross_zone_load_balancing = var.cross_zone

    subnet_mapping {
    subnet_id     = var.subnets[0]
    allocation_id = length(var.allocation_ids) > 0 ? var.allocation_ids[0] : null
    }    

    subnet_mapping {
    subnet_id     = var.subnets[1]
    allocation_id = length(var.allocation_ids) > 1 ? var.allocation_ids[1] : null
    }  

    tags = merge(
        {
            Name=var.name, 
        },
        var.common_tags,
    )
}

resource "aws_lb_target_group" "this" {
    name        = "tg-${var.name}"
    port        = var.port
    protocol    = var.protocol
    vpc_id      = var.vpc_id
    target_type = var.target_type

    health_check {
        healthy_threshold   = var.health_check_map.healthy_threshold
        interval            = var.health_check_map.interval
        protocol            = var.health_check_map.protocol
        unhealthy_threshold = var.health_check_map.unhealthy_threshold
    }

    stickiness {
    enabled = false # stickiness not supported in NLB
    type    = "lb_cookie"
    }

    tags = merge(
        {
            Name="tg-${var.name}", 
        },
        var.common_tags,
    )        
    depends_on = [aws_lb.this,]     
}    


resource "aws_lb_target_group_attachment" "this" {
    #count            = length(var.targets) # Causes - "count" value depends on resource attributes that cannot be determined until apply
    count            = var.target_count
    target_group_arn = aws_lb_target_group.this.arn
    target_id        = element(var.targets,count.index)
    port             = var.target_port
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.this.id
    port              = var.listener_app_port
    protocol          = var.listener_app_protocol

    default_action {
        target_group_arn = aws_lb_target_group.this.id
        type             = var.action_type
    }  

    depends_on = [aws_lb.this,aws_lb_target_group.this] 
}