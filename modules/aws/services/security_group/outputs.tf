

output "id" {
    value = aws_security_group.this.*.id
}

output "id_list" {
    value = zipmap(aws_security_group.this.*.name, aws_security_group.this.*.id)
}
