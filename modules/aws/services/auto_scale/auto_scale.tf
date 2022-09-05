resource "aws_launch_configuration" "as_conf" {
    name_prefix   = var.config_name
    image_id      = var.image_id
    instance_type = var.instance_type
    user_data     = var.user_data
    security_groups = var.security_groups
    key_name        = var.key_name
    iam_instance_profile = var.iam_instance_profile

    lifecycle {
    create_before_destroy = true
# User data is currently ignored. Comment the below lifecycle lines if you want to execute the user data.
    ignore_changes = [user_data]
    }
}

resource "aws_autoscaling_group" "auto" {
    name                 = var.autoscale_name
    launch_configuration = aws_launch_configuration.as_conf.name
    vpc_zone_identifier  = var.subnet_ids
    min_size             = var.min_size
    max_size             = var.max_size
    health_check_grace_period = var.health_check_grace_period 
    

    lifecycle {
    create_before_destroy = true
    }
} 