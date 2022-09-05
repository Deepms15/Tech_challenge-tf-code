

variable "interface_endpoints" {
    type=list
    default=[]
}

variable "gateway_endpoints" {
    type=list
    default=[]
}

variable "subnet_id_list" {
    type=map
    default={}
}

variable "security_group_id_list" {
    type=map
    default={}
}

variable "route_table_id_list" {
    type=map
    default={}
}

variable "vpc_id" {
    type=string
}

variable "common_tags" {
    type=map
    default={}
}

# variable "service_name" {
#     type=string
# }

# variable "endpoint_type" {
#     type=string
#     default=null
# }

# variable "security_group_ids" {
#     type=list
#     default=null
# }

# variable "subnet_ids" {
#     type=list
#     default=null
# }

# variable "private_dns_enabled" {
#     type=bool
#     default=null
# }



