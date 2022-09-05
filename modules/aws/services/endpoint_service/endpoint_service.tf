

variable "network_load_balancer_arns" {
    type=list
}

variable "allowed_principals" {
    type=list
    default=null
}

variable "acceptance_required" {
    type=bool
    default=true
}

variable "common_tags" {
    type=map
    default=null
}

variable "name" {
    type=string
    default="Endpoint Service"
}


resource "aws_vpc_endpoint_service" "this" {
    acceptance_required        = var.acceptance_required
    network_load_balancer_arns = var.network_load_balancer_arns
    allowed_principals         = var.allowed_principals

    tags = merge(
        {
            Name= var.name, 
        },
        var.common_tags,
    )
}


output "id" {
    value = aws_vpc_endpoint_service.this.id
}
output "name" {
    value = aws_vpc_endpoint_service.this.service_name
}
