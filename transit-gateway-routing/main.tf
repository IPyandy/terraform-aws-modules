resource "aws_ec2_transit_gateway_route" "this" {
  count                          = length(var.route_cidr_blocks)
  destination_cidr_block         = var.route_cidr_blocks[count.index]
  transit_gateway_attachment_id  = var.attachment_ids[count.index]
  transit_gateway_route_table_id = var.route_table_ids[count.index]
}
