


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

variable "common_tags" {
    type=map
    default={}
}

variable "log_bucket_name" {
  type=string
  default=null
}

variable "log_bucket_prefix" {
  type=string
  default=null
}

variable "access_logs_status" {
  type=bool
  default=false
}

variable "idle_timeout" { 
    type=number
    default = null
}

variable "enable_deletion_protection" {
    type = bool
    default = true
}