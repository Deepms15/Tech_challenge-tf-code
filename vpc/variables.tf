
variable "common_tags" {
  type        = map
  default     = {}
}

variable "aws" {
  type        = map
  default     = {}
}

variable "vpc_cidr_block" {
  type        = string
  default     = ""
}