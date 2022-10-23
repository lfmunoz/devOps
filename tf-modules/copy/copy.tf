


# ________________________________________________________________________________
# INPUT
# ________________________________________________________________________________
variable "config" {
  type = object({
      ssh_host = string
      ssh_port = number
      username = string
      password = string
      source = string
      destination = string
      execute = bool
  })
  default = {
      ssh_host = "localhost"
      ssh_port = 22,
      username = "root"
      password = "root"
      source = "",
      destination = ""
      execute = false
  }
}


# ________________________________________________________________________________
# NULL RESOURCE TO COPY FILES
# ________________________________________________________________________________
resource "null_resource" "copy" {

  # triggers = { always_run = "${timestamp()}" }

  connection {
    host     = var.config.ssh_host
    port     = var.config.ssh_port
    type     = "ssh"
    user     = var.config.username
    password = var.config.password
  }


  provisioner "file" {
    # absolute or relative path
    source = var.config.source
    # must be absolute path
    destination = var.config.destination
  }

}

# ________________________________________________________________________________
# EXEC COPIED FILE
# ________________________________________________________________________________
resource "null_resource" "exec" {
  count = var.config.execute ? 1 : 0

  depends_on = [null_resource.copy] 

  connection {
    host     = var.config.ssh_host
    port     = var.config.ssh_port
    type     = "ssh"
    user     = var.config.username
    password = var.config.password
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.config.destination}",
      "nohup ${var.config.destination} >> provision.log 2>&1",
    ]
  }
  
}


# ________________________________________________________________________________
# OUTPUT VARIABLES
# ________________________________________________________________________________
output "return" {
  value = "ok"
}

