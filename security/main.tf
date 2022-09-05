### Configure the AWS Provider
### Run "aws configure" to set the access_key and secret_key
provider "aws" {
  region      = var.aws["region"]
  profile     = var.aws["profile"]
}

terraform {
    backend "s3" {}

}

data "terraform_remote_state" "fabric" {
  backend = "s3"
  config = {
    bucket="terraform-backend-s3-tech"
    key="fabric/terraform.tfstate"
    region   = "ap-southeast-1"
    profile  = var.aws["profile"]    
  }
}
/*
data "terraform_remote_state" "SharedEndpoints" {
  backend = "s3"
  config = {
    bucket  = "pas-pa0001-mgmgnt-terraform-backend-store"
    key     = "security/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = var.aws["profile"]    
  }
}
*/
### module to create sg,sg_rules
module "security" {
  source                   = "../modules/aws/services/network_fabric"
  #vpc_id                   = var.vpc_id.fabric.outputs.vpc_id
  vpc_id                   = data.terraform_remote_state.fabric.outputs.fabric_map.vpc_id
  flags                    = var.flags
  common_tags              = var.common_tags
  
  ### fabric components
  subnets                  = var.subnets
  subnet_map               = data.terraform_remote_state.fabric.outputs.fabric_map.subnet_id_list
  routetable_map           = data.terraform_remote_state.fabric.outputs.fabric_map.route_table_id_list  
  security_groups          = var.security_groups
  security_group_rules     = var.security_group_rules
  source_security_group_rules = var.source_security_group_rules
  route_tables             = var.route_tables
  routes                   = var.routes
  route_table_associations = var.route_table_associations
  network_acls             = var.network_acls
  network_acl_rules        = var.network_acl_rules
  interface_endpoints      = var.interface_endpoints
  gateway_endpoints        = var.gateway_endpoints
}

output "securitygroup_map" {
  value = module.security
}
