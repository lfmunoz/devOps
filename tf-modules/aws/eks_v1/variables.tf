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

variable "additional_security_groups" {
  description = "Security groups to add to node instances for internal application communications"
  type = list(string)
}

variable "workers_additional_policies" {
  description = "IAM policies to add to node instances for internal application communications"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "eks_node_groups" {
  description = "A list node groups to provision to EKS."
  type        = list(object({
    name             = string
    desired_capacity = number
    min_capacity     = number
    max_capacity     = number
    instance_types   = list(string)
    capacity_type    = string
    user_data        = string
  }))
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

// convert the list of node groups to expected format (map of maps)
locals {
  node_groups = {
  for ng in var.eks_node_groups: ng["name"] =>
  {
    desired_capacity       = ng["desired_capacity"]
    min_capacity           = ng["min_capacity"]
    max_capacity           = ng["max_capacity"]
    instance_types         = ng["instance_types"]
    capacity_type          = ng["capacity_type"]
    user_data              = ng["user_data"]
    create_launch_template = true
    k8s_labels             = {
      apps = ng["name"]
    }
    additional_tags        = {
      Name       = ng["name"]
      Deployment = var.resource_prefix
    }
  }
  }
}

variable "private_eks_subnet_cidrs" {
  description = "List of private subnet CIDR's for EKS"
  type        = list(string)
  default     = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
}

variable "public_eks_subnet_cidrs" {
  description = "List of public subnet CIDR's for EKS"
  type        = list(string)
  default     = ["10.0.9.0/24", "10.0.10.0/24", "10.0.11.0/24"]
}

