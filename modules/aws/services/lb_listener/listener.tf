

variable "load_balancer_arn" {type=string}

variable "target_group_arn" {type=string}

variable "listener_app_port" {type=string}

variable "listener_app_protocol" {type=string}

variable "action_type" {
    type=string
    default = "forward"
}

variable "certificate_arn" {
    type=string
    default = null
}

variable "ssl_policy" {
    type=string
    default = null
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "this" {
    load_balancer_arn = var.load_balancer_arn
    port              = var.listener_app_port
    protocol          = var.listener_app_protocol
    certificate_arn   = var.certificate_arn
    ssl_policy        = var.ssl_policy
    default_action {
        target_group_arn = var.target_group_arn
        type             = var.action_type
    }  
}

output "arn" {
    value = aws_lb_listener.this.arn
}

