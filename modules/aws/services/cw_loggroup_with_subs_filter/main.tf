

resource "aws_cloudwatch_log_group" "log_group" {
  count             = length(var.log_group_name)
  name              = element(var.log_group_name, count.index)
  retention_in_days = var.logretention
  tags = var.common_tags
}

resource "aws_cloudwatch_log_subscription_filter" "log_subscription" {
  count             = length(var.log_group_name)
  name              = var.name
  log_group_name    = element(var.log_group_name, count.index)
  destination_arn   = var.destination_arn
  filter_pattern    = ""

  depends_on = [
    aws_cloudwatch_log_group.log_group
  ]

}