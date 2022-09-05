
resource "aws_lb" "this" {
    name                = var.name
    internal            = var.internal
    load_balancer_type  = var.lb_type
    #subnets             = var.subnets
    security_groups     = var.security_groups

    enable_cross_zone_load_balancing = var.cross_zone
    enable_deletion_protection = var.enable_deletion_protection     
    idle_timeout        = var.idle_timeout

    subnet_mapping {
    subnet_id     = var.subnets[0]
    allocation_id = length(var.allocation_ids) > 0 ? var.allocation_ids[0] : null
    }    

    subnet_mapping {
    subnet_id     = var.subnets[1]
    allocation_id = length(var.allocation_ids) > 1 ? var.allocation_ids[1] : null
    }  
/*
    access_logs {
    bucket  = var.log_bucket_name
    prefix  = var.log_bucket_prefix
    enabled = var.access_logs_status
    }    
*/
    tags = merge(
        {
            Name=var.name, 
        },
        var.common_tags,
    )
}