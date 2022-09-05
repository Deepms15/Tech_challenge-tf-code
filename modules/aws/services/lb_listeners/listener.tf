


variable "load_balancer_arn" {type=string}

variable "listeners" {
    type=list
    default = []
}

variable "target_groups" {
    type=map
    default = {}
}

resource "aws_lb_listener" "this" {
    count             = length(var.listeners)

    load_balancer_arn = var.load_balancer_arn
    port              = lookup(var.listeners[count.index],"port")  
    protocol          = lookup(var.listeners[count.index],"protocol")  
    certificate_arn   = lookup(var.listeners[count.index],"certificate_arn")  
    ssl_policy        = lookup(var.listeners[count.index],"ssl_policy") 

    default_action {
        target_group_arn = lookup(var.target_groups,lookup(var.listeners[count.index],"target_group"))
        type             = lookup(var.listeners[count.index],"action") 
    }  
}

output "listener_map" {
    value = zipmap(aws_lb_listener.this.*.id, aws_lb_listener.this.*.arn)
}