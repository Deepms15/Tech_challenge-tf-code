

variable "instance_count" {type=number}

variable "instance_name" {type=string}

variable "ami_id" { type=string}

variable "instance_type" { type=string}

variable "user_data" { 
    type=string
    default=null
}

variable "associate_pip" {
    type=bool
    default= false
}

variable "subnet_ids" {type=list}

variable "security_groups" {type=list}

variable "common_tags" { 
    type = map
    default = {}
}

variable "root_block_device" { 
    type = list
    default = []
}

variable "iam_instance_profile" {
    type=string
    default=null
}


variable "key_name" {
    type=string
    default=null
}

variable "root_vol_tags" { 
    type = map
    default = {}
}

variable "awsbackup_tags" { 
    type = map
    default = {}
}

variable "ec2_tags" { 
    type = map
    default = {}
}

variable "enable_deletion_protection" {
    type = bool
    default = true
}
