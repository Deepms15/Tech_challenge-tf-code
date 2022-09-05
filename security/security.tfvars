aws = {
    region = "ap-southeast-1"     
    profile = "Tech-challenge"  
}

#vpc_id is read from fabric state file
#vpc_id = "vpc-#################"

### add additional tags whenever needed
common_tags = {
    Author       = "Deepak"
    project-code = "Tech-challenge"
    environment  = "Test"
    creation     = "Terraform"
}
### create resource indicator flags
###   - true  = resource will be created/changed (depends on state)
###   - false = resource creation/change will be ignored
flags = {
    create_subnets                  = false
    create_security_groups          = true
    create_security_group_rules     = true
    create_security_group_egress_rules = true
    create_route_tables             = false
    create_route_table_associations = false
    create_routes                   = false
    create_network_acls             = false
    create_network_acl_rules        = false
}

security_groups = [
    {name="sgrp-pub-lb",description="pub alb sg",alias=""},
    {name="sgrp-ecs-app",description="app sg ",alias=""},
    {name="sgrp-rds-db",description="db sg",alias=""},    
    {name="sgrp-enpnt",description="endpoint sg",alias=""}, 
]

security_group_rules = [
   
    ##Allow the ports based on the requirements
    {name="sgrp-pub-lb", cidr_block="172.18.0.0/24", type="ingress", from_port="80",to_port="80",	protocol="tcp", description="alb sg"},
    {name="sgrp-ecs-app", cidr_block="172.18.0.0/24", type="ingress", from_port="80",to_port="80",	protocol="tcp", description="from alb"}, 
    {name="sgrp-ecs-app", cidr_block="172.18.0.0/24", type="ingress", from_port="3000",to_port="3000",	protocol="tcp", description="from alb"},       
    {name="sgrp-rds-db", cidr_block="172.18.0.0/24", type="ingress", from_port="5432",to_port="5432",	protocol="tcp", description="From app"},
    {name="sgrp-enpnt", cidr_block="172.18.0.0/24", type="ingress", from_port="0",	to_port="65535",	protocol="tcp", description="from vpc"},
    {name="sgrp-pub-lb", cidr_block="42.60.108.7/32", type="ingress", from_port="0",to_port="65535",	protocol="tcp", description="alb sg"},
    {name="sgrp-pub-lb", cidr_block="0.0.0.0/0", type="ingress", from_port="80",to_port="80",	protocol="tcp", description="alb sg"},
]

##Manually map the route tables for s3 gateway endpoints
gateway_endpoints = [
    {name="endp-s3", type="Gateway", service_name="com.amazonaws.ap-southeast-1.s3", route_table="rt-ac-epnt", purpose="S3 endpoint",alias="NA"},
]

interface_endpoints = [
    {name="endp-ecrdkr", type="Interface", service_name="com.amazonaws.ap-southeast-1.ecr.dkr", subnet=["sub-a-epnt","sub-c-epnt"], security_group="sgrp-enpnt", private_dns_enabled=true, purpose="ECR repo endpoint",alias="NA"},
    {name="endp-clwatch-logs", type="Interface", service_name="com.amazonaws.ap-southeast-1.logs", subnet=["sub-a-epnt","sub-c-epnt"], security_group="sgrp-enpnt", private_dns_enabled=true, purpose="Cloudwatch monitoring endpoint",alias="NA"}, 
    {name="endp-ecrapi", type="Interface", service_name="com.amazonaws.ap-southeast-1.ecr.api", subnet=["sub-a-epnt","sub-c-epnt"], security_group="sgrp-enpnt", private_dns_enabled=true, purpose="ECR API endpoint",alias="NA"}, 
    {name="endp-sts", type="Interface", service_name="com.amazonaws.ap-southeast-1.sts", subnet=["sub-a-epnt","sub-c-epnt"], security_group="sgrp-enpnt", private_dns_enabled=true, purpose="AWS STS endpoint",alias="NA"}, 
]
subnets = []
route_tables = []
route_table_associations = {}
routes = []
network_acls = []
network_acl_rules = []