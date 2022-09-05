

output "arn" {
    value = aws_lb.this.arn
}

output "nlb_hostname" {
  value = aws_lb.this.dns_name
}
