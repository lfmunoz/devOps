# ________________________________________________________________________________
# Inputs
# ________________________________________________________________________________
variable "resource_prefix" {
  type    = string
}

variable "private_subnet_cidrs" {
  description = "List of Private Subnet CIDR"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "public_subnet_cidrs" {
  description = "List of Public Subnet CIDR"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}


variable additional_public_subnet_tags {
  default = { }
}

variable additional_private_subnet_tags {
  default = { }
}

