# Transit Gateway Outputs

output "transit_gateway" {
  value = aws_ec2_transit_gateway.this[0]
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this[0].id
}

output "default_route_table_id" {
  value = aws_ec2_transit_gateway.this[0].association_default_route_table_id
}

output "transit_gateway_owner_id" {
  value = aws_ec2_transit_gateway.this[0].owner_id
}

# VPC Attachment Outputs

output "vpc_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.this[*]
}

output "vpc_attachment_ids" {
  value = aws_ec2_transit_gateway_vpc_attachment.this[*].id
}

# routing

output "route_tables" {
  value = aws_ec2_transit_gateway_route_table.this[*]
}

output "route_table_ids" {
  value = aws_ec2_transit_gateway_route_table.this[*].id
}

output "route_table_asssociations" {
  value = aws_ec2_transit_gateway_route_table_association.this[*]
}

output "route_table_association_ids" {
  value = aws_ec2_transit_gateway_route_table_association.this[*].id
}
