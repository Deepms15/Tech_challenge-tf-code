

variable "name" {type=string}

variable "internal" {
  type=string
  default=true
}

variable "port" {type=number}

variable "protocol" {type=string}

variable "vpc_id" {type=string}

variable "target_type" {type=string}

variable "listener_app_port" {type=string}

variable "listener_app_protocol" {type=string}

variable "subnets" { 
    type=list
    default = []
    }

variable "security_groups" { 
    type=list
    default = []
}

variable "health_check_map" {
    type=map
    default={}
}

variable "action_type" {
    type=string
    default = "forward"
}

variable "common_tags" {
    type=map
    default={}
}

variable "enable_deletion_protection" {
    type = bool
    default = true
}