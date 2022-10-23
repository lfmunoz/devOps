

# ________________________________________________________________________________
# INPUT
# ________________________________________________________________________________
variable "config" {
  default = {
    host = "localhost"
    name = "blank_name"
    scripts = []
    count  = 1
  }
}


# ________________________________________________________________________________
# MODULE TO COPY MULTIPLE FILES (AND POSSIBLY EXECUTE)
# ________________________________________________________________________________
module "copy_multiple" {
  count = (var.config.count != 0) ? length(var.config.scripts) : 0
  source = "../copy"
  config = {
    ssh_host    = var.config.host
    ssh_port    = 22
    username    = "root"
    password    = "root"
    source      = "${path.module}/../../provision_scripts/${var.config.scripts[count.index]}.bash",
    destination = "/root/${basename(var.config.scripts[count.index])}.bash"
    execute     = true
  }
}

