
locals {
  vpc_id = aws_vpc.this.id
  secondary_cidr_blocks = lookup(var.vpc,"secondary_cidr_blocks",null) == null ? [] : split(",",lookup(var.vpc,"secondary_cidr_blocks"))
}

resource "aws_vpc" "this" {
    # required
    cidr_block           = lookup(var.vpc,"cidr_block")
    # optional
    instance_tenancy     = lookup(var.vpc,"instance_tenancy", null)
    enable_dns_support   = lookup(var.vpc,"enable_dns_support", true)
    enable_dns_hostnames = lookup(var.vpc,"enable_dns_hostnames", false)
    enable_classiclink   = lookup(var.vpc,"enable_classiclink", false)
    assign_generated_ipv6_cidr_block = lookup(var.vpc,"assign_generated_ipv6_cidr_block", false)
    tags                 = merge(
      {
        Name = lookup(var.vpc,"name",null)
      }, 
      var.common_tags,
    )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
    count = length(local.secondary_cidr_blocks) > 0 ? length(local.secondary_cidr_blocks) : 0
    vpc_id = aws_vpc.this.id
    cidr_block = local.secondary_cidr_blocks[count.index]
}

