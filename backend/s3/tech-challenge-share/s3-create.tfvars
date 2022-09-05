
aws = {
    region = "ap-southeast-1"
    profile = "Tech-challenge" 
}



common_tags = {
    Author       = "Deep-tech"
    project-code = "Tech-challenge"
    environment  = "Test"
    creation     = "Terraform"
}

#--update backend tf statefile(init-s3-backend) and policy name with the bucketname wherever there is change in s3 
#====================================================
s3-bucket = "tech-challenge-s3-buckets"
#s3-log-folder = "challenge-share/"   #create the log folder based on the usage
#s3-log-bucket = "terraform-backend-s3-share" #update logging folder base on the compartment
