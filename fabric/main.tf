################################################
#Author Deepak
##################################################################3
### Add following block into you script to specify backend storage       
### Run the shell script "init-backend.sh" first to set the backend values 

### Configure the AWS Provider
### Run "aws configure" to set the access_key and secret_key

provider "aws" {
  region      = var.aws["region"]
  profile     = var.aws["profile"]
}

terraform {
    backend "s3" {}
}

###add the vpc tf state bucket here
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket="terraform-backend-s3-tech"
    key="vpc/terraform.tfstate"
    region = "ap-southeast-1"
    profile = var.aws["profile"]    
  }
}

### module to create fabric subnets,sg,sg_rules,routes
module "fabric" {
  source                   = "../modules/aws/services/network_fabric"
  #vpc_id                   = var.vpc_id
  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_map
  flags                    = var.flags
  common_tags              = var.common_tags
  
  ### fabric components
  subnets                  = var.subnets
  security_groups          = var.security_groups
  security_group_rules     = var.security_group_rules
  route_tables             = var.route_tables
  routes                   = var.routes
  route_table_associations = var.route_table_associations
  network_acls             = var.network_acls
  network_acl_rules        = var.network_acl_rules

}

output "fabric_map" {
  value = module.fabric
}
