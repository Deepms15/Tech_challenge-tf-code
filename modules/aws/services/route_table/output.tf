
output "id" {
    value = aws_route_table.this.*.id
}
output "id_list" {
    value = {
        for rt in aws_route_table.this :
        lookup(rt.tags,"Name") => rt.id
    }
}