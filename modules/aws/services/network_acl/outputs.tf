


output "ids" {
  value = aws_network_acl.this.*.id
}

output "id_list" {
    value = {
        for acl in aws_network_acl.this :
        lookup(acl.tags,"Name") => acl.id
    }
}