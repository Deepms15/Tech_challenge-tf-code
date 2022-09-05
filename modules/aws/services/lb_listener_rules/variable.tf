


variable "listener_arn" {type=string}

variable "priority" {type=number}

variable "target_group_arn" {type=string}

variable "action_type" {
    type=string
    default = "forward"
}

variable "path_patterns" {
    type=list
}

variable "host_header" {
    type=string
}