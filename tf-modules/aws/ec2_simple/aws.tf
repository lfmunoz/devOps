# ________________________________________________________________________________
# PROVIDERS
# ________________________________________________________________________________
# Providers should be configured by the user of the module and 
#  not by the module itself.

# A module intended to be called by one or more other modules must
#  not contain any provider blocks

# ________________________________________________________________________________
# INPUT VARIABLES
# ________________________________________________________________________________
variable "config" {
  default = {
    name = "blank_name"
    scripts = []
    type = "t2.micro"
    count  = 1
  }
}
# ________________________________________________________________________________
# AWS
# ________________________________________________________________________________
resource "aws_instance" "server" {

  ami = "ami-0739f8cdb239fe9ae"
  # t2.micro	1vcpu 	1 gig
  # t2.small  1vcpu 	2 gig
  # t2.medium 2vcpu 	4 gig
  # t2.large  2vcpu 	8 gig
  # t2.xlarge 4vcpu 	16 gig
  instance_type          = var.config.type
  vpc_security_group_ids = ["sg-040039cb63f60bdb4"]
  subnet_id              = "subnet-0868fc4b14c516ad0"
  key_name               = "eco-analytics-keypair"

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${path.root}/../certs/keypair.pem")
  }

  tags = {
    Name = var.name
  }

  provisioner "remote-exec" {
    scripts = ["${path.root}/../provision_scripts/docker_install.bash"]
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts
      echo ${self.public_ip} >> ${path.root}/../public-ip.txt
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    command = <<EOT
      ssh-keygen -R ${self.public_ip}
    EOT
  }

}

# ________________________________________________________________________________
# OUTPUT VARIABLES
# ________________________________________________________________________________
output "ipv4_address" {
  value = aws_instance.server.*.public_ip
}