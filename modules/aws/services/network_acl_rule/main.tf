

locals {
    csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    network_acl_rules = length(var.network_acl_rules) > 0 ? var.network_acl_rules : local.csvlist
}

resource "aws_network_acl_rule" "this" {
    count = length(local.network_acl_rules) > 0 && var.create ? length(local.network_acl_rules) : 0
    network_acl_id = var.network_acl_ids[lookup(local.network_acl_rules[count.index],"name")]
    egress = lookup(local.network_acl_rules[count.index],"type") == "ingress" ? "false" : "true"
    from_port = lookup(local.network_acl_rules[count.index],"from_port")
    to_port = lookup(local.network_acl_rules[count.index],"to_port")
    protocol = lookup(local.network_acl_rules[count.index],"protocol")
    cidr_block = lookup(local.network_acl_rules[count.index],"cidr_block")
    rule_number = lookup(local.network_acl_rules[count.index],"rule_number")
    rule_action = lookup(local.network_acl_rules[count.index],"rule_action")
}