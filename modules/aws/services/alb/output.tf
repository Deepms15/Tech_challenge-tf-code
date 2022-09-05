

output "arn" {
    value = aws_lb.alb.id
}

output "alb_hostname" {
  value = aws_lb.alb.dns_name
}

output "target_group" {
    value = aws_alb_target_group.app.id
}