##############################################################################################################
#
#           Author           Version            Remarks
#           Deepak           1.0            First version
#						
###############################################################################################################



locals {
  vpc_id = var.vpc_id
  security_groups_csvlist = fileexists(var.security_groups_csvfile) ? csvdecode(file(var.security_groups_csvfile)) : []
  security_groups = length(var.security_groups) > 0 ? var.security_groups : local.security_groups_csvlist
}

# subnets
module "subnet" {
  source      = "../subnet"
  subnets     = var.subnets
  csvfile     = var.subnets_csvfile
  vpc_id      = local.vpc_id
  common_tags = var.common_tags
  create      = lookup(var.flags,"create_subnets")
}

# security groups
module "security_group" {
  source          = "../security_group"
  security_groups = var.security_groups
  csvfile         = var.security_groups_csvfile
  vpc_id          = local.vpc_id
  common_tags     = var.common_tags
  create          = lookup(var.flags,"create_security_groups")
}

# default outbound security group rule to allow all network traffic
resource "aws_security_group_rule" "allow_all" {
  count             = length(local.security_groups) > 0 && lookup(var.flags,"create_security_group_egress_rules") ? length(local.security_groups) : 0
  security_group_id = module.security_group.id_list[lookup(local.security_groups[count.index],"name")]
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = lookup(local.security_groups[count.index],"description")
}

# security group rules
module "security_group_rule" {
  source                      = "../security_group_rule"
  security_group_rules        = var.security_group_rules
  source_security_group_rules = var.source_security_group_rules
  csvfile                     = var.security_group_rules_csvfile
  #id_list                     = merge(module.security_group.id_list,module.endpoint.gateway) #Causes sg rules to be recreated if new sg is added
  id_list                     = merge(module.security_group.id_list,var.addtnl_sgid_list)
  create                      = lookup(var.flags,"create_security_group_rules")
}

# route tables
module "route_table" {
  source       = "../route_table"
  vpc_id       = local.vpc_id
  route_tables = var.route_tables
  csvfile      = var.route_tables_csvfile
  common_tags  = var.common_tags
  create       = lookup(var.flags,"create_route_tables")
}

# routes
module "route" {
  source  = "../route"
  routes  = var.routes
  csvfile = var.routes_csvfile
  id_list = module.route_table.id_list
  create  = lookup(var.flags,"create_routes")
}

# route table associations
module "route_table_association" {
  source                   = "../route_table_association"
  route_tables             = var.route_tables
  route_table_id_list      = module.route_table.id_list
  subnet_id_list           = module.subnet.id_list
  route_table_associations = var.route_table_associations
  csvfile                  = var.route_table_associations_csvfile
  route_tables_csvfile     = var.route_tables_csvfile
  create                   = lookup(var.flags,"create_route_table_associations")
}

# network acl
module "network_acl" {
  source       = "../network_acl"
  network_acls = var.network_acls
  csvfile      = var.network_acls_csvfile
  vpc_id       = var.vpc_id
  subnet_id_list = module.subnet.id_list
  common_tags  = var.common_tags
  create       = lookup(var.flags,"create_network_acls")
}

# network acl rules
module "network_acl_rule" {
  source            = "../network_acl_rule"
  network_acl_rules = var.network_acl_rules
  csvfile           = var.network_acl_rules_csvfile
  network_acl_ids   = module.network_acl.id_list
  create            = lookup(var.flags,"create_network_acl_rules")
}

module "endpoint" {
    source = "../endpoint"

    vpc_id                  = var.vpc_id
    interface_endpoints     = var.interface_endpoints
    gateway_endpoints       = var.gateway_endpoints
    subnet_id_list          = var.subnet_map
    route_table_id_list     = var.routetable_map
    security_group_id_list  = module.security_group.id_list

    common_tags             = var.common_tags
}