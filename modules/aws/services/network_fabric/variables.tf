

variable "vpc_id" {
  type        = string
  default     = ""
}
variable "subnets" {
  type        = list
  default     = []
}
variable "common_tags" {
  type        = map
  default     = {}
}
variable "security_groups" {
  type        = list
  default     = []
}
variable "security_group_rules" {
  type        = list
  default     = []
}
variable "source_security_group_rules" {
  type        = list
  default     = []
}
variable "route_tables" {
  type        = list
  default     = []
}
variable "routes" {
  type        = list
  default     = []
}
variable "route_table_associations" {
  type        = map
  default     = {}
}
variable "flags" {
  type        = map
  default     = {}  
}
variable "subnets_csvfile" {
  type        = string
  default     = "subnet.csv"
}
variable "security_groups_csvfile" {
  type        = string
  default     = "security_groups.csv"
}
variable "security_group_rules_csvfile" {
  type        = string
  default     = "security_group_rules.csv"
}
variable "route_tables_csvfile" {
  type        = string
  default     = "route_tables.csv"
}
variable "route_table_associations_csvfile" {
  type        = string
  default     = "route_table_associations.csv"
}
variable "routes_csvfile" {
  type        = string
  default     = "routes.csv"
}
variable "network_acls" {
  type        = list
  default     = []
}
variable "network_acl_rules" {
  type        = list
  default     = []
}
variable "network_acls_csvfile" {
  type        = string
  default     = "nacls.csv"
}
variable "network_acl_rules_csvfile" {
  type        = string
  default     = "nacl_rules.csv"
}
variable "interface_endpoints" {
  type        = list
  default     = []
}
variable "gateway_endpoints" {
  type        = list
  default     = []
}
variable "subnet_map" {
  type        = map
  default     = {}
  description = "Map of subnet name and ids read from fabric layer state file"
}
variable "routetable_map" {
  type        = map
  default     = {}
  description = "Map of route table name and ids read from fabric layer state file"  
}

variable "addtnl_sgid_list" {
  type        = map
  default     = {}
  description = "Map of additional SG IDs from other VPCs to be used"
}