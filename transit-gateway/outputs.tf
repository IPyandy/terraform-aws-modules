# Transit Gateway Outputs

output "transit_gateway" {
  value = aws_ec2_transit_gateway[0]
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway[0].this.id
}

output "default_route_table_id" {
  value = aws_ec2_transit_gateway[0].this.association_default_route_table_id
}

output "transit_gateway_owner_id" {
  value = aws_ec2_transit_gateway[0].this.owner_id
}
