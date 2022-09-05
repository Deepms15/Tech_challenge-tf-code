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



variable "aws" {
  type        = map
  default     = {}
}
variable "s3" {
  type        = map
  default     = {}
}
variable "vpc_id" {
  type        = string
  default     = ""
}
variable "common_tags" {
  type        = map
  default     = {}
}
variable "nlb" {
  type = list
  default = []
}
variable "alb" {
  type = list
  default = []
}
variable "environment" {
  type = list
  default = []
}
variable "ecs_cluster" {
  type = list
  default = []
}



#--------------------------------------------------------------------------------------------------------

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default = "myEcsAutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "bradfordhamilton/crystal_blockchain:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

#--------------------------------------------------------------------------------------------------------
variable "subnets" {
  type        = list
  default     = []
}
variable "security_groups" {
  type        = list
  default     = []
}
variable "security_group_rules" {
  type        = list
  default     = []
}
variable "source_security_group_rules" {
  type        = list
  default     = []
}
variable "route_tables" {
  type        = list
  default     = []
}
variable "route_table_associations" {
  type        = map
  default     = {}
}
variable "routes" {
  type        = list
  default     = []
}
variable "flags" {
  type        = map
  default     = {}
}
variable "network_acls" {
  type        = list
  default     = []
}
variable "network_acl_rules" {
  type        = list
  default     = []
}

variable "cnames" {
  type        = map
  default     = {}
}

variable "listener_path_patterns" {
  type        = map
  default     = {}
}