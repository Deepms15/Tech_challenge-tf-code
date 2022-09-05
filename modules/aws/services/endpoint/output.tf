

output "gateway_endpoints" {
    value = {
        for gateway in aws_vpc_endpoint.gateway:
            #lookup(gateway.tags,"Name")  => gateway.prefix_list_id
            gateway.service_name  => gateway.prefix_list_id
    }
}

# output "interface_endpoints" {
#     value = {
#         for interface in aws_vpc_endpoint.interface:
#             interface.dns_entry[3].dns_name  => interface.dns_entry[0].dns_name
#             if interface.private_dns_enabled
#     }
# }


output "interface_endpoints" {
    value = {
        for interface in aws_vpc_endpoint.interface:
            interface.service_name  => interface.dns_entry
    }
}
