

locals {
    csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
    security_group_rules = length(var.security_group_rules) > 0 ? var.security_group_rules : local.csvlist
}

resource "aws_security_group_rule" "this" {
  count             = length(local.security_group_rules) > 0 && var.create ? length(local.security_group_rules) : 0
  # required
  security_group_id = var.id_list[lookup(local.security_group_rules[count.index],"name")]
  type              = lookup(local.security_group_rules[count.index],"type")
  from_port         = lookup(local.security_group_rules[count.index],"from_port")
  to_port           = lookup(local.security_group_rules[count.index],"to_port")
  protocol          = lookup(local.security_group_rules[count.index],"protocol")
  # optional
  cidr_blocks       = lookup(local.security_group_rules[count.index],"cidr_block", null) == null ? [] : split(",",lookup(local.security_group_rules[count.index],"cidr_block"))
  ipv6_cidr_blocks  = lookup(local.security_group_rules[count.index],"ipv6_cidr_blocks", null) == null ? [] : split(",",lookup(local.security_group_rules[count.index],"ipv6_cidr_blocks"))
  source_security_group_id = lookup(local.security_group_rules[count.index],"source_security_group_id", null)
  description       = lookup(local.security_group_rules[count.index],"description", null)
}

resource "aws_security_group_rule" "this_src" {
  count             = length(var.source_security_group_rules) > 0 && var.create ? length(var.source_security_group_rules) : 0
  # required
  security_group_id = var.id_list[lookup(var.source_security_group_rules[count.index],"name")]
  type              = lookup(var.source_security_group_rules[count.index],"type")
  from_port         = lookup(var.source_security_group_rules[count.index],"from_port")
  to_port           = lookup(var.source_security_group_rules[count.index],"to_port")
  protocol          = lookup(var.source_security_group_rules[count.index],"protocol")
  # optional
  source_security_group_id = lookup(var.id_list,lookup(var.source_security_group_rules[count.index],"source",""),null)
  prefix_list_ids          = lookup(var.source_security_group_rules[count.index],"source_prefixlist",null) == null ? null : [lookup(var.id_list,lookup(var.source_security_group_rules[count.index],"source_prefixlist"))]  
  description              = lookup(var.source_security_group_rules[count.index],"description", null)
}