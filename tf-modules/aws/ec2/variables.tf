# ________________________________________________________________________________
# INPUT VARIABLES
# ________________________________________________________________________________
variable "config" {
  default = {
    ami                 = "ami-0bcacfac640850227"
    key_name            = "TerraformClient"
    name                = "blank_name"
    security_groups_ids = []
    subnet_ids          = []
    user_data           = ""
    scripts             = []
    templates           = []
    type                = "t2.micro"
    count               = 1
  }
}

variable "resource_name_prefix" {
  type = string
}