
output "arn" {
  value = aws_cloudwatch_log_group.log_group.*.arn
}

output "name" {
  value = aws_cloudwatch_log_group.log_group.*.name
}

output "id" {
    value = aws_cloudwatch_log_subscription_filter.log_subscription.*.id
}
