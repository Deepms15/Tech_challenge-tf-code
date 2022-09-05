aws = {
    region = "ap-southeast-1"
    profile = "Tech-challenge" 
}
#vpc_id = "vpc-0d46e963d20wes60a"

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
    create_subnets                      = true
    create_security_groups              = false
    create_security_group_rules         = false
    create_security_group_egress_rules  = false
    create_route_tables                 = true
    create_route_table_associations     = false             ##associate the subnet manually
    create_routes                       = true
    create_network_acls                 = true
    create_network_acl_rules            = true
}

subnets = [
    #Internet CIDR Subnets
    {name="sub-a-pub", cidr_block="172.18.0.0/28", availability_zone="ap-southeast-1a", purpose="public subnet"},
    {name="sub-c-pub", cidr_block="172.18.0.16/28", availability_zone="ap-southeast-1c",purpose="public subnet"},
    {name="sub-a-app", cidr_block="172.18.0.32/28", availability_zone="ap-southeast-1a", purpose="app-subnet"},
    {name="sub-c-app", cidr_block="172.18.0.48/28", availability_zone="ap-southeast-1c",purpose="app-subnet"},
    {name="sub-a-db", cidr_block="172.18.0.64/28", availability_zone="ap-southeast-1a",purpose="db subnet"},
    {name="sub-c-db", cidr_block="172.18.0.80/28", availability_zone="ap-southeast-1c", purpose="db subnet"},
    {name="sub-a-epnt", cidr_block="172.18.0.96/28", availability_zone="ap-southeast-1a",purpose="endpoint subnet"},
    {name="sub-c-epnt", cidr_block="172.18.0.112/28", availability_zone="ap-southeast-1c", purpose="endpoint subnet"},
    
]

### map values format:
### {name="",description="",alias=""},
security_groups = []
security_group_rules = []

### map values format: 
### {name=""},
route_tables = [
    {name="rt-ac-pub"},
    {name="rt-ac-app"},
    {name="rt-ac-db"},
    {name="rt-ac-epnt"}, 
]



routes = [   

    ##internet gateway route from public subnet
    {name="rt-ac-pub", destination_cidr_block="0.0.0.0/0", gateway_id="igw-0e1f01e71bbffce10"} ##update your own igw id
   
    #{name="rt-ac-app", destination_cidr_block="172.16.0.0/28",vpc_peering_connection_id="pcx-027a6ded422e9a2c1"},
]

### map values format:
###{name="", purpose="",subnet=["subnet1","subnet2"], alias=""}
### subnet is optional, must be a list of length 2, if associating with one subnet use subnet=["subnet1",""]





network_acls = [
    {name="nacl-ac-pub", subnet=["sub-a-pub","sub-c-pub"], purpose="public",alias="NA"},
    {name="nacl-ac-app",subnet=["sub-a-app","sub-c-app"], purpose="app",alias="NA"},
    {name="nacl-ac-db",subnet=["sub-a-db","sub-c-db"], purpose="db",alias="NA"},
    {name="nacl-ac-enpnt",subnet=["sub-a-epnt","sub-c-epnt"], purpose="endpoint",alias="NA"},
]

s3endpoint_access_list = [
    "nacl-ac-pub",
    "nacl-ac-app",
]

### map values format: 
### {name="", rule_number="", rule_action="", cidr_block="", type="", protocol="", from_port="", to_port=""}
###   - ingress
###   - egress

network_acl_rules = [
    {name="nacl-ac-pub", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="ingress", protocol="-1", from_port="-1", to_port="-1"},
    {name="nacl-ac-pub", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="egress", protocol="-1", from_port="-1", to_port="-1"},
    
    {name="nacl-ac-app", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="ingress", protocol="-1", from_port="-1", to_port="-1"},
    {name="nacl-ac-app", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="egress", protocol="-1", from_port="-1", to_port="-1"},

    {name="nacl-ac-db", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="ingress", protocol="-1", from_port="-1", to_port="-1"},
    {name="nacl-ac-db", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="egress", protocol="-1", from_port="-1", to_port="-1"},

    {name="nacl-ac-enpnt", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="ingress", protocol="-1", from_port="-1", to_port="-1"},
    {name="nacl-ac-enpnt", rule_number="10000", rule_action="allow", cidr_block="0.0.0.0/0", type="egress", protocol="-1", from_port="-1", to_port="-1"},

]
