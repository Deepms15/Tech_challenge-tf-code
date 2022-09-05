
# This module can be used when the uat and prod have different instance counts.
# For example the uat has 1 instance and prod has 2 instance, in such case use this module for second instance.

resource "aws_ebs_volume" "this" {
    count       = var.create_volume ? 1 : 0    
    availability_zone = var.az
    size              = var.size
    type              = var.type
    encrypted         = var.encrypted
    tags = merge(
        {
            Name="${var.name}",    
        },
    var.common_tags,
    )
}

resource "aws_volume_attachment" "this" {
    count       = var.attach_to_instance ? 1 : 0    

    device_name = var.device_name
    volume_id   = aws_ebs_volume.this.*.id[0]
    instance_id = var.instance_id
}

output "id" {
    value = aws_ebs_volume.this.*.id
}