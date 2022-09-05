

variable "ssl_domains" {
    type=list
    default = []
    }

variable "statuses" {
    type = list
    default = ["ISSUED"]
}

variable "listener" {
    type=string
}


data "aws_acm_certificate" "cert" {
    count = length(var.ssl_domains)
    
    domain   = var.ssl_domains[count.index]
    statuses = var.statuses
}

resource "aws_lb_listener_certificate" "attach" {
    count = length(var.ssl_domains)

    listener_arn    = var.listener
    certificate_arn = data.aws_acm_certificate.cert[count.index].arn
}


