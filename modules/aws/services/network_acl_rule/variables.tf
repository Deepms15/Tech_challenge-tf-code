

variable "network_acl_rules" {
  type        = list
  default     = []
}
variable "network_acl_ids" {
  type        = map
  default     = {}
}
variable "csvfile" {
  type        = string
  default     = "default"
}
variable "create" {
  type        = bool
  default     = true
}