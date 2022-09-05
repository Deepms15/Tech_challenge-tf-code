aws = {
    region = "ap-southeast-1"     
    profile = "Tech-challenge"
}

### add additional tags whenever needed
common_tags = {
    Author       = "Deepak"
    project-code = "Tech-challenge"
    environment  = "Test"
    creation     = "Terraform"
}

#db subnet group
rds_sbgp =[
    {   
        name       = "tech-pg-sub-grp"
        subnets    = ["sub-a-db","sub-c-db"]

    }
]

#db instance
rds_pg = [
    {
        storage         = 20
        instance        = "db.t3.micro"
        azs             = "ap-southeast-1a"
        db-identifier   = "tech-challenge"
        db-engine       = "postgres"
        db-engine-ver   = "10.21"
        db-sg           = ["sgrp-rds-db"]
        db-name         = "app"
        db-username     = "postgres"
        db-port         = 5432
          
    }
]
