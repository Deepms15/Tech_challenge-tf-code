
variable "common_tags" {
  type        = map
  default     = {}
}
variable "s3-bucket" {
  type        = string
  default     = ""
}

variable "s3-log-folder" {
  type        = string
  default     = ""
}
variable "s3-log-bucket"{
  default     = ""
}
variable "aws" {
  type        = map
  default     = {}
}

