

variable "name" {
    type    = string
    default = "interface"
}

variable "description" {
    type    = string
    default = null
}

variable "source_dest_check" {
    type    = bool
    default = true
}

variable "subnet_id" {
    type    = string
}

variable "private_ips" {
    type    = list
    default = null
}

variable "private_ips_count" {
    type    = number
    default = null
}

variable "common_tags" {
    type    = map
    default = {}
}
variable "security_groups" {
    type    = list
    default = null
}

variable "instance_id" {
    type    = string
    default = null
}

variable "device_index" {
    type    = number
}

variable "attach" {
    type= bool
    default = false
}



resource "aws_network_interface" "this" {
    subnet_id           = var.subnet_id
    private_ips         = var.private_ips
    private_ips_count   = var.private_ips_count
    security_groups     = var.security_groups
    source_dest_check   = var.source_dest_check
    description         = var.description
    tags = merge(
        {
            Name="${var.name}", 
        },
        var.common_tags,
    )    
#  lifecycle {
#      ignore_changes = []
#  }

}

resource "aws_network_interface_attachment" "this" {
    count                = var.attach ? 1 : 0    

    instance_id          = var.instance_id
    network_interface_id = aws_network_interface.this.id
    device_index         = var.device_index
}

output "id" {
    value = aws_network_interface.this.id
}

output "private_ips" {
    value = aws_network_interface.this.private_ips
}
