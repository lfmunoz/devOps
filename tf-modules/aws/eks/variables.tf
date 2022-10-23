variable "resource_prefix" {
  type = string
}

variable "region" {
  description = "AWS region name"
  type = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type = string
}



variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "key_pair_name" {
  type        = string
}

variable "public_sg_id" {
  type        = string
}

variable "vpc_security_group_ids" {
  type        = list(string)
}