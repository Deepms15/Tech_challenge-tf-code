
variable "aws" {
  type        = map
  default     = {}
}

variable "common_tags" {
  type        = map
  default     = {}
}

variable "rds_pg" {
  default = []
}
variable "rds_sbgp" {
  default = []
}

variable "storage" {
  type        = number
  default     = "30"
}

variable "instance" {
  type        = string
  default     = ""
}

variable "azs" {
 type        = string
 default     = ""
}

variable "db-identifier" {
  type        = string
  default     = ""
}
variable "db-engine" {
  type        = string
  default     = ""
}

variable "db-engine-ver" {
  type        = number
  default     = "10.18"
}

variable "db-sg" {
  type        = list
  default     = []
}

variable "db-name" {
  type        = string
  default     = ""
}

variable "db-username" {
  type     = string
  default = "postgres"
}
variable "db-password" {}

variable "db-port" {
  type        = number
  default     = "5432"
}

variable "name" {
  type        = string
  default     = ""
}

variable "subnet_id" {
  type        = list(string)
  default     = []
}

