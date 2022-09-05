

variable "routes" {
  type        = list
  default     = []
}
variable "id_list" {
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