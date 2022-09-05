# To interface to the respective API for whatever provider we use
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #Comment out so it can download whatever is lastest 
      #version = "~> 3.0"
    }
  }
}
