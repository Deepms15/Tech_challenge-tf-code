
variable "aws" {
  type        = map
  default     = {}
}
variable "s3" {
  type        = map
  default     = {}
}
variable "vpc_id" {
  type        = string
  default     = ""
}
variable "common_tags" {
  type        = map
  default     = {}
}
variable "subnets" {
  type        = list
  default     = []
}
variable "security_groups" {
  type        = list
  default     = []
}
variable "security_group_rules" {
  type        = list
  default     = []
}
variable "route_tables" {
  type        = list
  default     = []
}
variable "route_table_associations" {
  type        = map
  default     = {}
}
variable "routes" {
  type        = list
  default     = []
}
variable "flags" {
  type        = map
  default     = {}
}
variable "network_acls" {
  type        = list
  default     = []
}
variable "network_acl_rules" {
  type        = list
  default     = []
}

variable "s3endpoint_access_list" {
  type        = list
  default     = []
}

