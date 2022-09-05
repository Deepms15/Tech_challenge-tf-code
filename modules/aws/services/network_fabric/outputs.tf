
output "subnet_id_list" {
  value = module.subnet.id_list
}

output "security_group_id_list" {
  value = module.security_group.id_list
}
/*output "security_group_id" {
  value = module.security_group.*.id
}*/
output "route_table_id_list" {
  value = module.route_table.id_list
}

output "nacl_id_list" {
  value = module.network_acl.id_list
}

output "vpc_id" {
  value = var.vpc_id
}

output "gateway_endpoints" {
  value = module.endpoint.gateway_endpoints
}

output "interface_endpoints" {
  value = module.endpoint.interface_endpoints
}
