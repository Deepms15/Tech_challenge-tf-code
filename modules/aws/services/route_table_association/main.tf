

locals {


    rta_csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    rta_csvmap = zipmap(local.rta_csvlist.*.route_table, local.rta_csvlist.*.subnet)
    route_table_associations = length(var.route_table_associations) > 0 ? var.route_table_associations : local.rta_csvmap
    #route_table_associations = length(var.route_table_associations) > 0 ? var.route_table_associations : local.rta_csvlist

    rt_csvlist = fileexists(var.route_tables_csvfile) ? csvdecode(file(var.route_tables_csvfile)) : []
    route_tables = length(var.route_tables) > 0 ? var.route_tables : local.rt_csvlist
}

resource "aws_route_table_association" "this" {
  #count = var.create && length(local.route_tables) > 0 ? length(local.route_tables) : 0

  #route_table_id = var.route_table_id_list[lookup(local.route_tables[count.index],"name")]
  #subnet_id = local.route_table_associations[lookup(local.route_tables[count.index],"name")]

  count = var.create ? length(var.route_table_associations) : 0

  route_table_id = var.route_table_id_list[keys(var.route_table_associations)[count.index]]  
  subnet_id = var.subnet_id_list[local.route_table_associations[keys(var.route_table_associations)[count.index]]]
}