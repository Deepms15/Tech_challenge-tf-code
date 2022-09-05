

variable "vpc_id" {
    type = string
}
variable "route_tables" {
    type    = list
    default = []
}
variable "gateway_id" {
    type    = string
    default = ""
}
variable "common_tags" {
    type    = map
    default = {}
}
variable "create" {
    type     = bool
    default  = true
}
variable "csvfile" {
    type    = string
    default = "default"
}