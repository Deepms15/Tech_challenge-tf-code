

variable "vpc_id" {
    type = "string"
}
variable "tags" {
    type = "map"
}
variable "common_tags" {
    type = "map"
    default = {}
}