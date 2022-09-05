


variable "name" {type=string}


variable "port" {type=number}

variable "protocol" {type=string}

variable "vpc_id" {type=string}

variable "target_type" {type=string}

variable "lb_type" {
    type=string
    default = ""
    }

variable "health_check_map" {
    type=map
    default={}
}

variable "targets" {
    type=list
    default=[]
}

variable "target_port" {
    type=number
    default = null
}

variable "common_tags" {
    type=map
    default={}
}