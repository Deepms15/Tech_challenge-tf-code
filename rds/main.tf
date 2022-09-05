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

locals {
    subnet_map               = data.terraform_remote_state.fabric.outputs.fabric_map.subnet_id_list
    security_group_map       = data.terraform_remote_state.security.outputs.securitygroup_map.security_group_id_list

    db_subnets = [
        for subnet in var.rds_sbgp[0].subnets:
            lookup(local.subnet_map,subnet)
    ]      
    db_security_groups = [
        for security_group in var.rds_pg[0].db-sg:
            lookup(local.security_group_map,security_group)
    ]    

}

# Create Database Subnet Group
# terraform aws db subnet group
resource "aws_db_subnet_group" "database-subnet-group" {
  name         = var.rds_sbgp[0].name
  subnet_ids   = local.db_subnets
  description  = "DB subnets"

  tags = {
      Name     = "My DB subnet group"
  }
}

# terraform aws db instance
module "rds-instance" {
    source = "./modules/postgres"
    
    allocated_storage           = var.rds_pg[0].storage
    instance_class              = var.rds_pg[0].instance
    availability_zone           = var.rds_pg[0].azs
    identifier                  = var.rds_pg[0].db-identifier
    engine                      = var.rds_pg[0].db-engine
    engine_version              = var.rds_pg[0].db-engine-ver
    db_subnet_group_name        = aws_db_subnet_group.database-subnet-group.name
    vpc_security_group_ids      = local.db_security_groups
    db_name                     = var.rds_pg[0].db-name
    username                    = var.rds_pg[0].db-username
    password                    = var.db-password
    port                        = var.rds_pg[0].db-port
    multi_az                    = false
    storage_encrypted           = true
    auto_minor_version_upgrade  = false
    skip_final_snapshot         = true
    tags                        = var.common_tags
}

output "rds_map" {
  value = module.rds-instance
}