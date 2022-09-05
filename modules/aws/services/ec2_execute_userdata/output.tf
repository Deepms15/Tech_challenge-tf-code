

output "ids" {
    value = aws_instance.this.*.id
}

output "id_list" {
    value = {
        for instance in aws_instance.this :
        lookup(instance.tags,"Name") => instance.id
    }
}