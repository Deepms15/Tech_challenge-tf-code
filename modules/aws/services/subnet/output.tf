
output "id" {
    value = aws_subnet.this.*.id
}

output "id_list" {
    value = {
        for subnet in aws_subnet.this :
        lookup(subnet.tags,"Name") => subnet.id
    }
}

