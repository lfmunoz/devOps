
# ________________________________________________________________________________
# AWS VPC
# ________________________________________________________________________________
resource "aws_vpc" "main_vpc" {
  # 2**16 = 65536
  cidr_block           =  "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name       = "${var.resource_prefix}-VPC"
    Deployment = var.resource_prefix
  }
}

# ________________________________________________________________________________
# AWS Internet Gateway for VPC
# ________________________________________________________________________________
# Enables communication between your VPC and the internet.
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name       = "${var.resource_prefix}-GW"
    Deployment = var.resource_prefix
  }
}

# ________________________________________________________________________________
# AWS Route Table for Subnets
# ________________________________________________________________________________
# 10.0.0.0/16    local
# 0.0.0.0/0      igw-0f163a49436f2eaff
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
  tags = {
    Name       = "${var.resource_prefix}-RT"
    Deployment = var.resource_prefix
  }
}

resource "aws_route" "main_rt_igw" {
  route_table_id         = aws_route_table.main_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_gw.id
}

resource "aws_main_route_table_association" "main_rt" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.main_rt.id
}

# ________________________________________________________________________________
#  Amazon EKS requires subnets in at least two Availability Zone, and creates up to
#   four network interfaces across these subnets to facilitate control plane 
#   communication to your nodes. 
# ________________________________________________________________________________
data "aws_availability_zones" "azs" {
  state = "available"
}

# ________________________________________________________________________________
# Private Subnet
# ________________________________________________________________________________
# creates private subnet for each of our subnet_cidrs 
#    default     = ["10.0.0.0/24", "10.0.1.0/24"]
# A private subnet sets the route to a NAT instance. Need a private ip 
#  and internet traffic is routed through the NAT in the public subnet. 
#  You could also have no route to 0.0.0.0/0 to make it a truly private 
#   subnet with no internet access in or out.
resource "aws_subnet" "private_subnets" {
  depends_on        = [aws_internet_gateway.main_gw]
  count             = length(var.private_subnet_cidrs)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.main_vpc.id


  tags = merge({
    Name       = "${var.resource_prefix}-PrivateSubnet-${count.index + 1}"
    Tier       = "Private"
    Deployment = var.resource_prefix
  }, var.additional_private_subnet_tags)
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  // create NAT gateway in the public subnet
  subnet_id = aws_subnet.public_subnets[0].id

  tags = {
    Name       = "${var.resource_prefix}-NatGW"
    Deployment = var.resource_prefix
  }
}


resource "aws_route_table" "nat_gateway_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name       = "${var.resource_prefix}-NatGW-RT"
    Deployment = var.resource_prefix
  }
}

resource "aws_route" "nat_gw_rt" {
  route_table_id         = aws_route_table.nat_gateway_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "nat_gateway_ta" {
  count = length(aws_subnet.private_subnets)
  // route traffic from private subnet to the NAT gateway
  // NAT gateway is in a public subnet with an internet GW
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.nat_gateway_rt.id
}


# ________________________________________________________________________________
# Public Subset
# ________________________________________________________________________________
# A public subnet routes 0.0.0.0/0 through an Internet Gateway (igw). 
#   default     = ["10.0.3.0/24", "10.0.4.0/24"]
#  Instances in a public subnet require public IPs to talk to the internet.
resource "aws_subnet" "public_subnets" {
  depends_on        = [aws_internet_gateway.main_gw]
  count             = length(var.public_subnet_cidrs)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = var.public_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.main_vpc.id

  # instances launched into the subnet should be assigned a public IP addres
  map_public_ip_on_launch = true

  tags = merge({
    Name       = "${var.resource_prefix}-PublicSubnet-${count.index + 1}"
    Tier       = "Public"
    Deployment = var.resource_prefix
  }, var.additional_public_subnet_tags)
}

resource "aws_route_table_association" "associations" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.main_rt.id
}

# ________________________________________________________________________________
# AWS Security Groups
# ________________________________________________________________________________
locals {
  public_sg     = "${var.resource_prefix}-PublicSecurityGroup"
  main_sg       = "${var.resource_prefix}-MainSecurityGroup"
}

// security group for internal access
// ec2 to ec2
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = local.main_sg

  tags = {
    Name       = local.main_sg
    Deployment = var.resource_prefix
  }

  # allow all outbound traffic
  egress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # permit Inbound connections from itself (that is, the security group has its own ID 
  #  as the Source of the inbound connection) . This enables any EC2 instance that is 
  # associated with the security group to communicate with any other Amazon EC2 instance 
  # that is associated with the same security group. there is no concept of multiple instances 
  # being "inside a security group" the security group is applied against traffic as 
  # it goes into each instance. 
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }


}

# Security for public access
# internet to ec2
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = local.public_sg
  tags = {
    Name       = local.public_sg
    Deployment = var.resource_prefix
  }

  # allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Access"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "wireguard"
    from_port   = 51820
    to_port     = 51820 
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS ACCESS"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

