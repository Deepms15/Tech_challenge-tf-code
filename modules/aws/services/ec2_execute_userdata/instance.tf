

resource "aws_instance" "this" {
    count = var.instance_count

    ami                           = var.ami_id
    instance_type                 = var.instance_type
    associate_public_ip_address   = var.associate_pip
    subnet_id                     = element(var.subnet_ids,count.index)
    vpc_security_group_ids        = length(var.security_groups) > 0 ? var.security_groups : null
    key_name                      = var.key_name
    iam_instance_profile          = var.iam_instance_profile 
    disable_api_termination       = var.enable_deletion_protection
    user_data                     = var.user_data
    
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

  #  lifecycle {
  #  ignore_changes = [user_data]
  #  }      

    #volume_tags = var.common_tags
    volume_tags = merge(
            var.root_vol_tags,
            var.common_tags,
    )

    tags = merge(
        {
            Name= var.instance_count>1 ? "${var.instance_name}-${count.index}":"${var.instance_name}", 
        },
        var.awsbackup_tags,
        var.common_tags,
        var.ec2_tags,
    )
}