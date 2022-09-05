#### Author Deepak

provider "aws" {
  region      = var.aws["region"]
  profile     = var.aws["profile"]    
}

terraform {
    backend "s3" {}
}


resource "aws_vpc" "vpc-tf" {

    cidr_block = var.vpc_cidr_block
    instance_tenancy = "default"

    tags = var.common_tags
    
}

resource "aws_internet_gateway" "igw-tf" {
    vpc_id = aws_vpc.vpc-tf.id
     tags = var.common_tags
}

output "vpc_map" {
  value       = aws_vpc.vpc-tf.id
  description = "vpc id."
}
