
output "launch_configuration_id" {
    value = aws_launch_configuration.as_conf.id
}

output "autoscaling_group_id" {
    value = aws_autoscaling_group.auto.id
} 