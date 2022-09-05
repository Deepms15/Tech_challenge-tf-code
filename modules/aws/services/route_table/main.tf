

locals {
    csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    route_tables = length(var.route_tables) > 0 ? var.route_tables : local.csvlist
}

resource "aws_route_table" "this" {
  count = length(local.route_tables) > 0 && var.create ? length(local.route_tables) : 0
  vpc_id = var.vpc_id
  tags = merge(
      {
        Name = lookup(local.route_tables[count.index],"name"),
        Purpose = lookup(local.route_tables[count.index],"purpose",null),
        Alias = lookup(local.route_tables[count.index],"alias",null)
      },
      var.common_tags
  )
}
