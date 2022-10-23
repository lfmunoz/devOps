
locals {
  az = data.aws_availability_zones.azs.names
}

data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_group" "main_sg" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.resource_prefix}-MainSecurityGroup"
  }
}

data "aws_security_group" "public_sg" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.resource_prefix}-PublicSecurityGroup"
  }
}

// setup the public subnet with the internet gateway
resource "aws_subnet" "eks_public_subnet" {
  count             = length(var.public_eks_subnet_cidrs)
  availability_zone = local.az[count.index]
  cidr_block        = var.public_eks_subnet_cidrs[count.index]
  vpc_id            = var.vpc_id

  tags = {
    Name                                        = "${var.resource_prefix}-EKS-PublicSubnet-${count.index + 1}"
    Deployment                                  = var.resource_prefix
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_route_table" "internet_gateway_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "internet_gateway_ta" {
  count = length(var.public_eks_subnet_cidrs)
  subnet_id = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.internet_gateway_rt.id
}

// setup the private subnet with a NAT gateway
resource "aws_subnet" "eks_private_subnet" {
  count             = length(var.private_eks_subnet_cidrs)
  availability_zone = local.az[count.index]
  cidr_block        = var.private_eks_subnet_cidrs[count.index]
  vpc_id            = var.vpc_id

  tags = {
    Name                                        = "${var.resource_prefix}-EKS-PrivateSubnet-${count.index + 1}"
    Deployment                                  = var.resource_prefix
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "eks_nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  // create NAT gateway in the public subnet
  subnet_id = aws_subnet.eks_public_subnet[0].id

  tags = {
    Name       = "${var.resource_prefix}-EKS-NatGW"
    Deployment = var.resource_prefix
  }
}

resource "aws_route_table" "nat_gateway_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway.id
  }
}

resource "aws_route_table_association" "nat_gateway_ta" {
  count = length(var.private_eks_subnet_cidrs)
  // route traffic from private subnet to the NAT gateway
  // NAT gateway is in a public subnet with an internet GW
  subnet_id = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.nat_gateway_rt.id
}

output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}

output "list_private_eks_subnet_ids" {
  description = "The list of private eks subnet ID's for control and nodes"
  value       = aws_subnet.eks_private_subnet[*].id
}

output "list_public_eks_subnet_ids" {
  description = "The list of public eks subnet ID's for control and nodes"
  value       = aws_subnet.eks_public_subnet[*].id
}
