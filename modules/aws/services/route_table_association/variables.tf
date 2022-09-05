

variable "route_tables" {
  type        = list
  default     = []
}
variable "route_table_id_list" {
  type        = map
  default     = {}
}
variable "route_table_associations" {
 type        = map
  default     = {}
}
variable "create" {
  type        = bool
  default     = true
}
variable "csvfile" {
    type    = string
    default = "default"
}
variable "route_tables_csvfile" {
    type    = string
    default = "default"
}

variable "subnet_id_list" {
  type        = map
  default     = {}
}
