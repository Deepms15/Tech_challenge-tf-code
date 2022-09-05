

variable "name" {type=string}

#variable "role_arn" {type=string}

variable "log_group_name" {type=string}

variable "filter_pattern" {
    type=string
    default = ""
    }

variable "destination_arn" {type=string}

variable "distribution" {
    type=string
    default = null
    }
