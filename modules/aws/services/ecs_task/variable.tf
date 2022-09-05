


variable "cluster_id" {type=string}

variable "name" {type=string}

variable "exec_role_arn" {type=string}

variable "security_groups" {type=list}

variable "subnets" {type=list}

# variable "target_group_arn" {
#     type=string
#     default=null
#     }

variable "target_group_arns" {
   type        = list
    default     = []
}

variable "template_file" {type=string}

variable "task_definition" {
    type=map
    default={}
}

variable "service" {
    type=map
    default={}
}

variable "common_tags" {
    type        = map
    default     = {}
}
variable "environment" {
    type        = list
    default     = []
}
variable "health_check_grace_period_seconds" {
    type=number
    default = 30
}

variable "volume_name" {
    type=string
    default = "tw_policy"
    }