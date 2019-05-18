resource "aws_ec2_transit_gateway" "this" {
  count                           = var.create_transit_gateway ? 1 : 0
  description                     = var.transit_gateway_description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  tags                            = var.transit_gateway_tags
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count                                           = var.create_transit_gateway && length(var.vpc_ids) > 0 ? length(var.vpc_ids) : 0
  vpc_id                                          = var.vpc_ids[count.index]
  subnet_ids                                      = var.subnet_ids[count.index]
  transit_gateway_id                              = aws_ec2_transit_gateway.this[0].id
  dns_support                                     = var.dns_support
  ipv6_support                                    = var.ipv6_support
  transit_gateway_default_route_table_association = var.associate_default_route_table
  transit_gateway_default_route_table_propagation = var.vpc_default_route_table_propagation
  tags                                            = var.vpc_attachment_tags[count.index]
}
