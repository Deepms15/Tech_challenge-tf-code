

locals {
    csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    network_acls = length(var.network_acls) > 0 ? var.network_acls : local.csvlist
}

resource "aws_network_acl" "this" {
    count  = length(local.network_acls) > 0 && var.create ? length(local.network_acls) : 0
    vpc_id = var.vpc_id
    #subnet_ids = lookup(local.network_acls[count.index],"subnet_ids",null) == null ? [] : split(lookup(local.network_acls[count.index],"subnet_ids"))
    subnet_ids = length(lookup(local.network_acls[count.index],"subnet")) == 2 ? [lookup(var.subnet_id_list,lookup(local.network_acls[count.index],"subnet")[0]),lookup(var.subnet_id_list,lookup(local.network_acls[count.index],"subnet")[1],lookup(var.subnet_id_list,lookup(local.network_acls[count.index],"subnet")[0]))] : null
    
    tags   = merge(
        {
            Name = lookup(local.network_acls[count.index],"name")
            Purpose = lookup(local.network_acls[count.index],"purpose","")
            Alias = lookup(local.network_acls[count.index],"alias","")
        },
        var.common_tags
    )

    dynamic "ingress" {
        for_each = lookup(local.network_acls[count.index],"ingress_rules",[])
        content {
            protocol        = lookup(ingress.value,"protocol")
            rule_no         = lookup(ingress.value,"rule_no")
            action          = lookup(ingress.value,"action")
            cidr_block      = lookup(ingress.value,"cidr_block")
            from_port       = lookup(ingress.value,"from_port")
            to_port         = lookup(ingress.value,"to_port")
        }
    }

    dynamic "egress" {
        for_each = lookup(local.network_acls[count.index],"egress_rules",[])
        content {
            protocol        = lookup(egress.value,"protocol")
            rule_no         = lookup(egress.value,"rule_no")
            action          = lookup(egress.value,"action")
            cidr_block      = lookup(egress.value,"cidr_block")
            from_port       = lookup(egress.value,"from_port")
            to_port         = lookup(egress.value,"to_port")
        } 
    }
}