
data "aws_ip_ranges" "southeastasia_s3" {
    regions  = var.regions
    services = var.services
}

locals {
    ip_ranges = "${data.aws_ip_ranges.southeastasia_s3.cidr_blocks}"
    rules     = setproduct(var.nacl_ids, local.ip_ranges)
}

resource "aws_network_acl_rule" "s3_ingress" {
    count          = length(local.rules)

    network_acl_id = local.rules[count.index][0]

    rule_number    = "20100"+count.index
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = local.rules[count.index][1]
    from_port      = 1024
    to_port        = 65535
}

resource "aws_network_acl_rule" "s3_egress" {
    count          = length(local.rules)

    network_acl_id = local.rules[count.index][0]

    rule_number    = "20100"+count.index
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = local.rules[count.index][1]
    from_port      = 443
    to_port        = 443
}