

locals {
   document_list = {
     for key, value in var.ssm_document :
     value.name => value
   }
}

resource "aws_ssm_document" "ssm_document" {
    for_each = local.document_list
    name = lookup(each.value, "name")
  document_type = "Command"
  content = file(lookup(each.value, "command_json", null)) 
  tags = merge(
        {
            Name= lookup(each.value, "name"), 
        },
        var.common_tags,
    )
}

resource "aws_ssm_association" "cw_ssm_doc_association" {
    for_each = local.document_list
    name = lookup(each.value, "name")
    association_name = lookup(each.value, "name")
  targets {
    key    = "tag:ssm_cw_agent"
    values = [lookup(each.value, "name")]
  }

depends_on = [aws_ssm_document.ssm_document]

}