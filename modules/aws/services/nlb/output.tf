
output "nlb" {
    value = aws_lb.this.id
}

output "nlb_hostname" {
  value = aws_lb.this.dns_name
}

output "target_group" {
    value = aws_lb_target_group.this.id
}