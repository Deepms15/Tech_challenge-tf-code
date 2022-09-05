
variable "log_group_name" {
  description = "List of log group names"
  type        = list
  default     = []
}

variable "logretention" {
  description = "Log group retention in days"
   type=string
   default = "90"
}

variable "name" {
  description = "subscription filter name"
   type=string
}

variable "filter_pattern" {
    type=string
    default = ""
}

variable "destination_arn" {
  type        = string
  default     = ""
}

variable "distribution" {
    type=string
    default = null
}

variable "common_tags" { 
    type = map
    default = {}
}
