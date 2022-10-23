# ________________________________________________________________________________
# AWS
# ________________________________________________________________________________
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "server" {
  count = var.config.count
  ami   = var.config.ami
  # t2.micro	1vcpu 	1 gig
  # t2.small  1vcpu 	2 gig
  # t2.medium 2vcpu 	4 gig
  # t2.large  2vcpu 	8 gig
  # t2.xlarge 4vcpu 	16 gig
  instance_type               = var.config.type
  vpc_security_group_ids      = var.config.security_groups_ids
  subnet_id                   = var.config.subnet_ids[count.index % length(var.config.subnet_ids)]
  key_name                    = var.config.key_name
  associate_public_ip_address = true

  user_data = var.config.user_data

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/../../../certs/${self.key_name}.pem")
  }

  tags = {
    cluster    = "LFM"
    Name       = "${var.config.name}_${count.index}"
    Deployment = var.resource_name_prefix
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 3
      ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts
      echo ${self.public_ip} > ${path.root}/public-ip.txt
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      ssh-keygen -R ${self.public_ip}
    EOT
  }

}

# ________________________________________________________________________________
# OUTPUT VARIABLES
# ________________________________________________________________________________

output "return" {
  value = [for index, value in aws_instance.server : {
    name       = value.tags["Name"]
    public_ip  = value.public_ip
    private_ip = value.private_ip
    scripts    = var.config.scripts
    templates  = var.config.templates
  }]
}

output "debug" {
  value = aws_instance.server
}
/*
[
  {                                                                                                                                                                          
        "ami" = "ami-0739f8cdb239fe9ae"                                                                                                                                          
        "arn" = "arn:aws:ec2:us-east-1:018954509966:instance/i-0600b06996444b4f5"                                                                                                
        "associate_public_ip_address" = true                                                                                                                                     
        "availability_zone" = "us-east-1a"                                                                                                                                       
        "cpu_core_count" = 1                                                                                                                                                     
        "cpu_threads_per_core" = 1                                                                                                                                               
        "credit_specification" = [                                                                                                                                               
          {                                                                                                                                                                      
            "cpu_credits" = "standard"                                                                                                                                           
          },                                                                                                                                                                     
        ]                                                                                                                                                                        
        "disable_api_termination" = false                                                                                                                                        
        "ebs_block_device" = []                                                                                                                                                  
        "ebs_optimized" = false                                                                                                                                                  
        "ephemeral_block_device" = []                                                                                                                                            
        "get_password_data" = false                                                                                                                                              
        "hibernation" = false                                                                                                                                                    
        "iam_instance_profile" = ""                                                                                                                                              
        "id" = "i-0600b06996444b4f5"                                                                                                                                             
        "instance_state" = "running"                                                                                                                                             
        "instance_type" = "t2.micro"                                                                                                                                             
        "ipv6_address_count" = 0                                                                                                                                                 
        "ipv6_addresses" = []                                                                                                                                                    
        "key_name" = "eco-analytics-keypair"                                                                                                                                     
        "metadata_options" = [
          {
            "http_endpoint" = "enabled"
            "http_put_response_hop_limit" = 1
            "http_tokens" = "optional"
          },
        ]
        "monitoring" = false
        "network_interface" = []
        "outpost_arn" = ""
        "password_data" = ""
        "placement_group" = ""
        "primary_network_interface_id" = "eni-08a9a0915d0a81d64"
        "private_dns" = "ip-10-0-0-139.ec2.internal"
        "private_ip" = "10.0.0.139"
        "public_dns" = "ec2-54-161-0-82.compute-1.amazonaws.com"
        "public_ip" = "54.161.0.82"
        "root_block_device" = [
          {
            "delete_on_termination" = true
            "device_name" = "/dev/sda1"
            "encrypted" = false
            "iops" = 100
            "kms_key_id" = ""
            "volume_id" = "vol-066850300175eb7f9"
            "volume_size" = 8
            "volume_type" = "gp2"
          },
        ]
        "security_groups" = []
      "source_dest_check" = true                                                                                                                                               
        "subnet_id" = "subnet-0868fc4b14c516ad0"                                                                                                                                 
        "tags" = {                                                                                                                                                               
          "cluster" = "LFM"                                                                                                                                                      
          "name" = "web1_0"                                                                                                                                                      
        }                                                                                                                                                                        
        "tenancy" = "default"                                                                                                                                                    
        "volume_tags" = {}                                                                                                                                                       
        "vpc_security_group_ids" = [                                                                                                                                             
          "sg-040039cb63f60bdb4",                                                                                                                                                
        ]                                                                                                                                                                        
      },        


      
      {                                                                                                                                                                          
        "ami" = "ami-0739f8cdb239fe9ae"                                                                                                                                          
        "arn" = "arn:aws:ec2:us-east-1:018954509966:instance/i-0916e4bd9521733c4"                                                                                                
        "associate_public_ip_address" = true                                                                                                                                     
        "availability_zone" = "us-east-1a"                                                                                                                                       
        "cpu_core_count" = 1                                                                                                                                                     
        "cpu_threads_per_core" = 1                                                                                                                                               
        "credit_specification" = [                                                                                                                                               
          {                                                                                                                                                                      
            "cpu_credits" = "standard"                                                                                                                                           
          },                                                                                                                                                                     
        ]                                                                                                                                                                        
        "disable_api_termination" = false
        "ebs_block_device" = []
        "ebs_optimized" = false
        "ephemeral_block_device" = []
        "get_password_data" = false
        "hibernation" = false
        "iam_instance_profile" = ""
        "id" = "i-0916e4bd9521733c4"
        "instance_state" = "running"
        "instance_type" = "t2.micro"
        "ipv6_address_count" = 0
        "ipv6_addresses" = []
        "key_name" = "eco-analytics-keypair"
        "metadata_options" = [
          {
            "http_endpoint" = "enabled"
            "http_put_response_hop_limit" = 1
            "http_tokens" = "optional"
          },
        ]
        "monitoring" = false
        "network_interface" = []
        "outpost_arn" = ""
        "password_data" = ""
        "placement_group" = ""
        "primary_network_interface_id" = "eni-0cab61e5332f41b66"
        "private_dns" = "ip-10-0-0-202.ec2.internal"
        "private_ip" = "10.0.0.202"
        "public_dns" = "ec2-54-166-221-168.compute-1.amazonaws.com"
        "public_ip" = "54.166.221.168"
        "root_block_device" = [
           {
             "delete_on_termination" = true
             "device_name" = "/dev/sda1"
             "encrypted" = false
             "iops" = 100
             "kms_key_id" = ""
             "volume_id" = "vol-0f1b4edef0392f0df"
             "volume_size" = 8
             "volume_type" = "gp2"
           },
         ]
         "security_groups" = []
         "source_dest_check" = true
         "subnet_id" = "subnet-0868fc4b14c516ad0"
         "tags" = {
           "cluster" = "LFM"
           "name" = "web1_1"
         }
         "tenancy" = "default"
         "volume_tags" = {}
         "vpc_security_group_ids" = [
           "sg-040039cb63f60bdb4",
         ]
       },
     ]
   }
]

*/
