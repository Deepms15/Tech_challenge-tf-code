

variable "az" {type=string}

variable "size" {
    type=string
    default = "1"
    }

variable "type" {
    type=string
    default = "gp2"
}

variable "name" {type=string}

variable "common_tags" {
    type=map
    default={}
}

variable "attachment" {
    type=string
    default=""
}

variable "device_name" {
    type=string
    default=""
}

variable "instance_id" {
    type=string
    default=""
}

variable "attach_to_instance" {
    type = bool
    default = false
}

variable "encrypted" {
    type = bool
    default = true
}

variable "create_volume" {
    type = bool
    default = false
}
