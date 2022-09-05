

locals {
    csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    subnets = length(var.subnets) > 0 ? var.subnets : local.csvlist
}

resource "aws_subnet" "this" {
    count                   = length(local.subnets) > 0 && var.create ? length(local.subnets) : 0
    # required
    vpc_id                  = var.vpc_id
    cidr_block              = local.subnets[count.index].cidr_block
    # optional
    ipv6_cidr_block         = lookup(local.subnets[count.index],"ipv6_cidr_block",null)
    map_public_ip_on_launch = lookup(local.subnets[count.index],"map_public_ip_on_launch",false)
    assign_ipv6_address_on_creation = lookup(local.subnets[count.index],"assign_ipv6_address_on_creation",false)
    availability_zone       = lookup(local.subnets[count.index],"availability_zone",null)
    availability_zone_id    = lookup(local.subnets[count.index],"availability_zone_id",null)
    tags                    = merge(
        {
            Name=local.subnets[count.index].name, 
            Purpose=lookup(local.subnets[count.index],"purpose",null),
            Alias=lookup(local.subnets[count.index],"alias",null)
        }, 
        var.common_tags,
    )
}
