locals {
  subnet_count = ((var.create_subnet && length(var.ipv4_subnets) > 0) ? length(var.ipv4_subnets) :
  var.create_subnet && var.num_subnets > 0 ? var.num_subnets : 0)
}
