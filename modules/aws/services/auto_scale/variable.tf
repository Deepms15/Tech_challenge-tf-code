 

variable "config_name" {
    type = string
}

variable "autoscale_name" {
    type = string
}

variable "image_id" {
    type = string
}
variable "instance_type" {
    type = string
}

variable "min_size" {
    type = number
    default = 1
}

variable "max_size" {
    type = number
    default = 2
}

variable "user_data" { 
    type=string
    default=null
}

variable "subnet_ids" { 
    type=list
    default=null
}

variable "security_groups" { 
    type=list
    default=null
}

variable "iam_instance_profile" {
    type = string
    default = null
}

variable "key_name" {
    type = string
    default = null
}
variable "health_check_grace_period" {
    type = number
    default = 120
}
 