##############################################################################################################
# Module            : gcc-pa
#
# Date                      Author                   Version            Remarks
# 1/8/2019              Sanju Vivek Pattali            1.0            First version
#						Praveen Muchandi
#
# NOTICE:////////////////////////////////////////////////////////////////////////////////////////////////
#
# Copyright 2020 Singapore Telecommunications Limited - All Rights Reserved
#
# Unauthorized use, copy and distribution this file is strictly prohibited
##############################################################################################################



variable "subnets" {
    type    = list
    default = []
}
variable "vpc_id" {
    type    = string
    default = ""
}
variable "common_tags" {
    type    = map
    default = {}
}
variable "create" {
    type    = bool
    default = true
}
variable "csvfile" {
  type        = string
  default     = "default"
}