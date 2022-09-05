

variable "listener_arn" {type=string}

variable "priority" {type=number}

variable "target_group_arn" {type=string}

variable "action_type" {
    type=string
    default = "forward"
}

variable "condition_field" {
    type=string
    default = "path-pattern"
}

variable "condition_value" {
    type=string
}

# Forward action

resource "aws_lb_listener_rule" "this" {
    listener_arn = var.listener_arn
    priority     = var.priority

    action {
    type             = var.action_type
    target_group_arn = var.target_group_arn
    }

    condition {
    field  = var.condition_field
    values = [var.condition_value]
    }
}