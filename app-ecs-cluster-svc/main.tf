
### Configure the AWS Provider
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
    bucket="terraform-backend-s3bucket-name-newly-created-for-statefiles"    
    key="fabric/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = var.aws["profile"]    
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket="terraform-backend-s3bucket-name-newly-created-for-statefiles"
    key="security/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = var.aws["profile"]
  }
}

data "terraform_remote_state" "lb" {
  backend = "s3"
  config = {
    bucket="terraform-backend-s3bucket-name-newly-created-for-statefiles"
    key="rpxy-lb/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = var.aws["profile"]    
  }
}

locals {
    subnet_map               = data.terraform_remote_state.fabric.outputs.fabric_map.subnet_id_list
    security_group_map       = data.terraform_remote_state.security.outputs.securitygroup_map.security_group_id_list 

    usr_ecs_subnets = [
        for subnet in var.usr_ecs_cluster[0].subnets:
            lookup(local.subnet_map,subnet)
    ] 

    usr_ecs_security_groups = [
        for security_group in var.usr_ecs_cluster[0].security_groups:
            lookup(local.security_group_map,security_group)
    ]

    app_target_group_arns = [
      [data.terraform_remote_state.lb.outputs.app_target_group,var.usr_ecs_cluster[0].service.port]
    ]

}


### module to ecs stack
#module "user_rp_ecs" {
module "app_ecs" {
  source                   = "../modules/aws/services/fargate_service"
  
  vpc_id                   = data.terraform_remote_state.fabric.outputs.fabric_map.vpc_id

  name                     = "app-${var.name}"
  # subnet_map               = data.terraform_remote_state.fabric.outputs.fabric_map.subnet_id_list
  # security_group_map       = data.terraform_remote_state.security.outputs.securitygroup_map.security_group_id_list
  # alb_config               = var.alb
  ecs_config               = var.usr_ecs_cluster
  ecs_subnets              = local.usr_ecs_subnets
  ecs_security_groups      = local.usr_ecs_security_groups
  #target_group_arn         = data.terraform_remote_state.lb.outputs.usr_target_group
  target_group_arns        = local.app_target_group_arns  
  #target_group_arns        = local.target_groups.arn_map
  common_tags              = var.common_tags
}
/*
output "user_rp_ecs" {
  value = module.user_rp_ecs
}
*/
output "app_ecs" {
  value = module.app_ecs
}