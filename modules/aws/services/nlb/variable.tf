


variable "name" {type=string}

variable "lb_type" {
  type=string
  default="network"
  description="application/network"
}

variable "security_groups" { 
    type=list
    default = null
}

variable "internal" {
  type=string
  default=true
}

variable "cross_zone" {
  type=string
  default=true
}

variable "subnets" { 
    type=list
    default = []
}

variable "allocation_ids" {
    type = list
    default = []
}


variable "port" {type=number}

variable "protocol" {type=string}

variable "vpc_id" {type=string}

variable "target_type" {type=string}

variable "listener_app_port" {type=string}

variable "listener_app_protocol" {type=string}

variable "targets" { 
    type=list
    default = []
}    

variable "target_count" { 
    type=number
    default = 0
}  

variable "target_port" {
  type=number
  default=null
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