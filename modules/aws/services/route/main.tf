

locals {
    csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    routes = length(var.routes) > 0 ? var.routes : local.csvlist
}

resource "aws_route" "this" {
  count                       = length(local.routes) > 0 && var.create ? length(local.routes) : 0
  route_table_id              = var.id_list[lookup(local.routes[count.index],"name")]
  
  # only one destination should be supplied
  destination_cidr_block      = lookup(local.routes[count.index],"destination_cidr_block", null)
  destination_ipv6_cidr_block = lookup(local.routes[count.index],"destination_ipv6_cidr_block", null)

  # only one target should be supplied
  egress_only_gateway_id      = lookup(local.routes[count.index],"egress_only_gateway_id", null)
  gateway_id                  = lookup(local.routes[count.index],"gateway_id", null)
  instance_id                 = lookup(local.routes[count.index],"instance_id", null)
  nat_gateway_id              = lookup(local.routes[count.index],"nat_gateway_id", null)
  network_interface_id        = lookup(local.routes[count.index],"network_interface_id", null)
  transit_gateway_id          = lookup(local.routes[count.index],"transit_gateway_id", null)
  vpc_peering_connection_id   = lookup(local.routes[count.index],"vpc_peering_connection_id", null)
  #internet_gateway_id         = lookup(local.routes[count.index],"internet_gateway_id", null)
  
}
