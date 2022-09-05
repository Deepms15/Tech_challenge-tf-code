


resource "aws_network_interface" "eth0" {
  count = var.instance_count

  subnet_id       = element(var.subnet_ids,count.index)
  private_ips     = var.private_ip
  private_ips_count = var.private_ips_count
  security_groups = length(var.security_groups) > 0 ? var.security_groups : null
}

resource "aws_instance" "this" {
    count = var.instance_count

    ami                           = var.ami_id
    instance_type                 = var.instance_type
    key_name                      = var.key_name
    iam_instance_profile          = var.iam_instance_profile 
    disable_api_termination       = var.enable_deletion_protection    
    user_data                     = var.user_data
    network_interface { 
      network_interface_id = aws_network_interface.eth0[count.index].id
      device_index = 0
    }
    
    dynamic "root_block_device" {
        for_each = var.root_block_device
        content {
        delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
        encrypted             = lookup(root_block_device.value, "encrypted", null)
        iops                  = lookup(root_block_device.value, "iops", null)
        kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
        volume_size           = lookup(root_block_device.value, "volume_size", null)
        volume_type           = lookup(root_block_device.value, "volume_type", null)
        }
    }

   # volume_tags = var.root_vol_tags
  volume_tags = merge(
            var.root_vol_tags,
            var.common_tags,
    )

    tags = merge(
        {
            Name= var.instance_count>1 ? "${var.instance_name}-${count.index}":"${var.instance_name}",
            "Patch Group" = "${var.patchgrouptag}", 
        },
        var.awsbackup_tags,
        var.common_tags,
        var.ec2_tags,
    )

# User data is currently ignored. Comment the below lifecycle lines if you want to execute the user data.
   lifecycle {
      ignore_changes = [user_data]
    }

}