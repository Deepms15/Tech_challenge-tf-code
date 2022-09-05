

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
        matcher             = var.lb_type == "application" ? var.health_check_map.matcher : null ##enable for alb if required
        timeout             = var.lb_type == "application" ? var.health_check_map.timeout : null
        path                = var.lb_type == "application" ? var.health_check_map.path : null
    }

    stickiness {
    enabled = false # stickiness not supported in NLB
    #type    = "source_ip" ##change to lb_cookie for alb if asked
    type    = "lb_cookie" ##change to lb_cookie for alb if asked
    }

    tags = merge(
        {
            Name="tg-${var.name}", 
        },
        var.common_tags,
    )        
}    

resource "aws_lb_target_group_attachment" "this" {
    count = length(var.targets)
    target_group_arn = aws_lb_target_group.this.arn
    target_id        = element(var.targets,count.index)
    port             = var.target_port
}