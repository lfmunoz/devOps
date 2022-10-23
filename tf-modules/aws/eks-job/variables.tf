variable "resource_prefix" {
  type = string
}

variable "service" {
  description = "Details of the service to be deployed"
  type = object({
    name       = string
    image      = string
    replicas   = number
  })
}

variable "command" {
    description = "command to use for image"
    #example:
    # command = ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
    default = []
}

variable "env_variables" {
  description = "Environmental variables for application."
  default     = []
}
