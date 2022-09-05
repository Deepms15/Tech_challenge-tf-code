# To interface to the respective API for whatever provider we use
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #Comment out to download the latest
      #version = "~> 3.0"
    }
  }
}
