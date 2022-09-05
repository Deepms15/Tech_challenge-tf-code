


variable "vpc_id" {type=string}

variable "target_groups" {
    type=list
    default=[]
}

variable "common_tags" {
    type=map
    default={}
}