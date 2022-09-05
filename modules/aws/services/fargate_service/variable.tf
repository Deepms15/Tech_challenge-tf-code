


variable "name" {type = string}

variable "vpc_id" {type = string}

# variable "target_group_arn" {
#     type=string
#     default=null
# }

variable "target_group_arns" {
    type        = list
    default     = []
    }

variable "ecs_config" {
    type = list
}

variable "ecs_subnets" {
    type = list
}

variable "ecs_security_groups" {
    type = list
}

variable "environment" {
    type = list
    default = []
}

variable "common_tags" {
    type=map
    default={}
}