

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
    bucket="terraform-backend-s3-tech"    
    key="fabric/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = var.aws["profile"]    
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket="terraform-backend-s3-tech"
    key="security/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = var.aws["profile"]
  }
}

locals {
    subnet_map               = data.terraform_remote_state.fabric.outputs.fabric_map.subnet_id_list
    security_group_map       = data.terraform_remote_state.security.outputs.securitygroup_map.security_group_id_list

    alb_subnets = [
        for subnet in var.alb[0].subnets:
            lookup(local.subnet_map,subnet)
    ]      
    alb_security_groups = [
        for security_group in var.alb[0].security_groups:
            lookup(local.security_group_map,security_group)
    ]    

}


module "lb" {
  source               = "../modules/aws/services/lb"  
  name                  = var.alb[0].name
  subnets               = local.alb_subnets
  security_groups       = local.alb_security_groups
  cross_zone            = true
  internal              = false
  lb_type               = "application"
  idle_timeout          = 180
  #log_bucket_name       = "pas-pa0001-web-${var.common_tags.environment}-alb-logs"
  #log_bucket_prefix     = "internet/rp_lb"
  access_logs_status    = true
  enable_deletion_protection = false  

  common_tags           = var.common_tags
}



module "app_target_group" {
  source               = "../modules/aws/services/lb_target_group"  
  name                  = var.alb[0].usr.target_group.name
  vpc_id                = data.terraform_remote_state.fabric.outputs.fabric_map.vpc_id
  port                  = var.alb[0].usr.target_group.port
  protocol              = var.alb[0].usr.target_group.protocol
  target_type           = var.alb[0].usr.target_group.target_type
  health_check_map      = var.alb[0].usr.target_group.healthcheck
  lb_type               = "application"
  common_tags           = var.common_tags
}


module "app_listener" {
  source               = "../modules/aws/services/lb_listener"  


  load_balancer_arn     = module.lb.arn
  listener_app_port     = var.alb[0].listener.port
  listener_app_protocol = var.alb[0].listener.protocol
  action_type           = var.alb[0].listener.type
  #Default action to user target group
  target_group_arn      = module.app_target_group.arn
}


output "rp_lb" {
    value = module.lb
}


output "app_target_group" {
    value = module.app_target_group.arn
}
