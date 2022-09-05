

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

variable "private_ip" {
    type=list
    default=null
    }

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

variable "patchgrouptag" { 
    type=string
    default=null
}

variable "private_ips_count" {
    type=number
    default=null
    }

variable "enable_deletion_protection" {
    type = bool
    default = true
}

variable "ec2_tags" { 
    type = map
    default = {}
}
