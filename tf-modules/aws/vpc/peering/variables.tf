
variable "resource_prefix" {
  type    = string
}
variable "main_vpc_id" {
    type    = string
}

variable "peering_vpc_id" {
    type    = string
}

variable "peering_cidr_block" {
    type    = string
}

variable "route_table_id" {
    type = string
}