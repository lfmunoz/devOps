# ________________________________________________________________________________
# Outputs
# ________________________________________________________________________________
output "main_vpc" {
    value = aws_vpc.main_vpc
}

output "main_rt" {
    value = aws_route_table.main_rt
}

output "list_private_subnet_ids" {
    description = "The ids of all the private subnets "
    value       = aws_subnet.private_subnets[*].id
}

output "list_public_subnet_ids" {
    description = "The ids of all the public subnets "
    value       = aws_subnet.public_subnets[*].id
}

output "main_sg" {
    value = aws_security_group.main_sg
}

output "public_sg" {
    value = aws_security_group.public_sg
}

output  "main_gw" {
    value  = aws_internet_gateway.main_gw
} 

