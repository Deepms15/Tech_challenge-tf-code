

variable "vpc" {
    type = "map"
}
variable "tags" {
    type = "map"
    default = {}
}
variable "common_tags" {
    type = "map"
    default = {}
}
variable "secondary_cidr_blocks" {
    type = "list"
    default = []
}