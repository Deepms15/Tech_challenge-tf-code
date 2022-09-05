

resource "aws_ebs_volume" "this" {
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
    volume_id   = aws_ebs_volume.this.id
    instance_id = var.instance_id
}

output "id" {
    value = aws_ebs_volume.this.id
}