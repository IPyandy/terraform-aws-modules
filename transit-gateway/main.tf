resource "aws_ec2_transit_gateway" "this" {
  count                           = var.create_transit_gateway ? 1 : 0
  description                     = var.transit_gateway_description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.create_custom_route_tables ? "disable" : var.default_route_table_association
  default_route_table_propagation = var.create_custom_route_tables ? "disable" : var.default_route_table_propagation
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
  transit_gateway_default_route_table_association = var.create_custom_route_tables ? false : var.associate_default_route_table
  transit_gateway_default_route_table_propagation = var.create_custom_route_tables ? false : var.vpc_default_route_table_propagation
  tags                                            = var.vpc_attachment_tags[count.index]
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  count              = var.create_custom_route_tables && var.route_table_count > 0 ? var.route_table_count : 0
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id
  tags               = var.route_table_tags[count.index]
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count                          = var.create_custom_route_tables && var.route_table_count > 0 ? var.route_table_count : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[count.index].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  count                          = var.create_custom_route_tables && var.route_table_count > 0 ? var.route_table_count : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[count.index].id
}
