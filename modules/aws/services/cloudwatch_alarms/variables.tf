variable "cw_specs" {
        type    = list
  default = []
}
variable "environment" {
    type    = string
  default = "no"
}
variable "csvfile" {
    type    = string
  default = "default"
}
variable "create_cw" {
    type    = string
  default = "no"
}
variable "common_tags" { 
    type = map
    default = {}
}