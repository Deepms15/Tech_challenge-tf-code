
variable "log_group" {type=string}

variable "retention" {type=number}

variable "common_tags" {type=map}


# Set up CloudWatch group and log stream
resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group
  retention_in_days = var.retention

  tags = merge(
      {
          Name="${var.log_group}", 
      },
      var.common_tags,
  )  
}

output "arn" {
  value = aws_cloudwatch_log_group.log_group.arn
}

output "name" {
  value = aws_cloudwatch_log_group.log_group.name
}