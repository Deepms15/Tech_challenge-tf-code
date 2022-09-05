

resource "aws_vpc_endpoint" "gateway" {
    count             = length(var.gateway_endpoints)
    
    vpc_id            = var.vpc_id
    service_name      = lookup(var.gateway_endpoints[count.index],"service_name")
    vpc_endpoint_type = "Gateway"
    #route_table_ids   = [lookup(var.route_table_id_list,lookup(var.gateway_endpoints[count.index],"route_table"))]
    tags = merge(
        {
            Name = lookup(var.gateway_endpoints[count.index],"name"), 
        },
        var.common_tags,
    )
}

resource "aws_vpc_endpoint" "interface" {
    count             = length(var.interface_endpoints)

    vpc_id            = var.vpc_id
    service_name      = lookup(var.interface_endpoints[count.index],"service_name")
    vpc_endpoint_type = "Interface"
    security_group_ids= [lookup(var.security_group_id_list,lookup(var.interface_endpoints[count.index],"security_group"))]
    subnet_ids        = length(lookup(var.interface_endpoints[count.index],"subnet")) == 2 ? [lookup(var.subnet_id_list,lookup(var.interface_endpoints[count.index],"subnet")[0]),lookup(var.subnet_id_list,lookup(var.interface_endpoints[count.index],"subnet")[1])] : [lookup(var.subnet_id_list,lookup(var.interface_endpoints[count.index],"subnet")[0])]

    private_dns_enabled = lookup(var.interface_endpoints[count.index],"private_dns_enabled")

    tags = merge(
        {
            Name = lookup(var.interface_endpoints[count.index],"name"), 
        },
        var.common_tags,
    )
}


