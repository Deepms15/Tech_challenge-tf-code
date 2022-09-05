

locals {
  csvlist = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
  security_groups = length(var.security_groups) > 0 ? var.security_groups : local.csvlist
}

# Create Network Security Group
resource "aws_security_group" "this" {
  count       = length(local.security_groups) > 0 && var.create ? length(local.security_groups) : 0
  name        = local.security_groups[count.index].name
  name_prefix = lookup(local.security_groups[count.index],"name_prefix",null)
  description = lookup(local.security_groups[count.index],"description",null)
  revoke_rules_on_delete = lookup(local.security_groups[count.index],"revoke_rules_on_delete",false)
  tags        = merge(
    {
        Name=local.security_groups[count.index].name, 
        Purpose=lookup(local.security_groups[count.index],"purpose",null),
        Alias=lookup(local.security_groups[count.index],"alias",null)
    },
    var.common_tags,
  )
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = lookup(local.security_groups[count.index],"ingress_rules",[])    
    content {
      # required 
      from_port        = lookup(ingress.value,"from_port")
      to_port          = lookup(ingress.value,"to_port")
      protocol         = lookup(ingress.value,"protocol")
      # optional
      cidr_blocks      = lookup(ingress.value,"cidr_blocks",[])
      ipv6_cidr_blocks = lookup(ingress.value,"ipv6_cidr_blocks",[])
      security_groups  = lookup(ingress.value,"security_groups",[])
      prefix_list_ids  = lookup(ingress.value,"prefix_list_ids",[])
      description      = lookup(ingress.value,"description",null)
    }
  }

  dynamic "egress" {
    for_each = lookup(local.security_groups[count.index],"egress_rules",[])
    content {
      # required 
      from_port        = lookup(egress.value,"from_port")
      to_port          = lookup(egress.value,"to_port")
      protocol         = lookup(egress.value,"protocol")
      # optional
      cidr_blocks      = lookup(egress.value,"cidr_blocks",[])
      ipv6_cidr_blocks = lookup(egress.value,"ipv6_cidr_blocks",[])
      security_groups  = lookup(egress.value,"security_groups",[])
      prefix_list_ids  = lookup(egress.value,"prefix_list_ids",[])
      description      = lookup(egress.value,"description",null)
    } 
  }
}
