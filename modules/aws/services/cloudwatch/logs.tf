 

variable "app_name" {type=string}

variable "log_group" {type=string}

variable "retention" {type=number}

variable "common_tags" {type=map}




# Set up CloudWatch group and log stream
resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group
  retention_in_days = var.retention

  tags = merge(
      {
          Name="${var.app_name}-log-group", 
      },
      var.common_tags,
  )  
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.app_name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

output "arn" {
  value = aws_cloudwatch_log_group.log_group.arn
}

output "name" {
  value = aws_cloudwatch_log_group.log_group.name
}