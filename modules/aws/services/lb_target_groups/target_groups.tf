


resource "aws_lb_target_group" "this" {
    count = length(var.target_groups)

    name        = lookup(var.target_groups[count.index],"name")
    port        = lookup(var.target_groups[count.index],"port")
    protocol    = lookup(var.target_groups[count.index],"protocol")
    vpc_id      = var.vpc_id
    target_type = lookup(var.target_groups[count.index],"target_type")

    health_check {
        healthy_threshold   = "2" #lookup(var.target_groups[count.index],"health_threshold")
        interval            = lookup(var.target_groups[count.index],"health_interval")
        protocol            = lookup(var.target_groups[count.index],"protocol")
        unhealthy_threshold = lookup(var.target_groups[count.index],"health_threshold")
        matcher             = lookup(var.target_groups[count.index],"health_matcher")
        timeout             = lookup(var.target_groups[count.index],"health_timeout")
        path                = lookup(var.target_groups[count.index],"health_path")
    }

    stickiness {
   # enabled = false # stickiness not supported in NLB
    enabled = lookup(var.target_groups[count.index],"stickiness", false)
    type    = "lb_cookie"
    }



    tags = merge(
        {
            Name="${lookup(var.target_groups[count.index],"name")}", 
        },
        var.common_tags,
    )        
}    


output "arn_map" {
    value = zipmap(aws_lb_target_group.this.*.name, aws_lb_target_group.this.*.arn)
}
