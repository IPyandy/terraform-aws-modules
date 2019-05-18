output "routes" {
  value = aws_ec2_transit_gateway_route.this[*]
}

output "route_ids" {
  value = aws_ec2_transit_gateway_route.this[*].id
}

