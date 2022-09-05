

variable "security_groups" {
    type    = list
    default = []
}

variable "vpc_id" {
    type = string
}

variable "common_tags" {
    type    = map
    default = {}
}
variable "create" {
    type    = bool
    default = true
}
variable "csvfile" {
    type    = string
    default = "default"
}