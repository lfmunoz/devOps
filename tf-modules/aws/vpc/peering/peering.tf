# ________________________________________________________________________________
# AWS VPC Peering Connection
# ________________________________________________________________________________
resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id   = var.main_vpc_id
  vpc_id        = var.peering_vpc_id
  auto_accept   = true
  tags = {
    Name       = "${var.resource_prefix}-Peer2-${var.peering_vpc_id}"
    Deployment = var.resource_prefix
  }
}

# ________________________________________________________________________________
# Update route tables to enable traffic to be directed between the peered VPCs
# ________________________________________________________________________________
resource "aws_route" "managed_peer_connections" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.peering_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  depends_on = [
    aws_vpc_peering_connection.this
  ]
}