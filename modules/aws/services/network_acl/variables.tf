


variable "network_acls" {
    type = list
    default = []
}
variable "vpc_id" {
    type = string
}
variable "csvfile" {
  type        = string
  default     = "default"
}
variable "common_tags" {
  type        = map
  default     = {}
}
variable "create" {
  type        = bool
  default     = true
}
variable "subnet_id_list" {
  type        = map
  default     = {}
}