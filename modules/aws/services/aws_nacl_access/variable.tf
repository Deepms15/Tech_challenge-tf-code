

variable "nacl_ids" { 
    type=list
    default = []
}

variable "regions" {
    type=list
    default=["ap-southeast-1"]
}

variable "services" {
    type=list
    default = ["s3"]
}
