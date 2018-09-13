# TODO: DUALSTACK + MANUAL IPV4 + AUTO IPV6 + RANDOM AZ [✓]
# TODO: DUALSTACK + MANUAL IPV4 + AUTO IPV6 + MANUAL AZ [✓]
# TODO: DUALSTACK + MANUAL IPV4 + MANUAL IPV6 + RANDOM AZ [✓]
# TODO: DUALSTACK + MANUAL IPV4 + MANUAL IPV6 + MANUAL AZ [✓]
# TODO: DUALSTACK + AUTO IPV4 + AUTO IPV6 + RANDOM AZ [✓]
# TODO: DUALSTACK + AUTO IPV4 + AUTO IPV6 + MANUAL AZ [✓]
# TODO: DUALSTACK + AUTO IPV4 + MANUAL IPV6 + RANDOM AZ [✓]
# TODO: DUALSTACK + AUTO IPV4 + MANUAL IPV6 + MANUAL AZ [✓]

data "aws_availability_zones" "azs" {}

locals {
  subnet_count = "${(var.create_subnet && length(var.ipv4_subnets) > 0) ?
                    length(var.ipv4_subnets) : var.create_subnet &&
                            var.num_subnets > 0 ? var.num_subnets : 0}"
}

resource "random_shuffle" "random_az" {
  input        = ["${data.aws_availability_zones.azs.names}"]
  result_count = "${length(data.aws_availability_zones.azs.names)}"
}

resource "aws_subnet" "this" {
  count                           = "${local.subnet_count}"
  vpc_id                          = "${var.vpc_id}"
  map_public_ip_on_launch         = "${var.map_public}"
  assign_ipv6_address_on_creation = "${var.ipv6_on_create}"
  tags                            = "${var.tags}"

  availability_zone = "${length(var.azs) > 0 ?
                          element(coalescelist(var.azs, list("")), count.index) :
                          random_shuffle.random_az.result[count.index]}"

  cidr_block = "${length(var.ipv4_subnets) > 0 ?
                  element(coalescelist(var.ipv4_subnets, list("")), count.index) :
                  cidrsubnet(var.ipv4_cidr_block, var.ipv4_newbits, var.ipv4_netnum + count.index)}"

  ipv6_cidr_block = "${length(var.ipv6_cidr_subnets) > 0 && length(var.ipv6_cidr_subnets) >= local.subnet_count  ?
                      element(coalescelist(var.ipv6_cidr_subnets, list("")), count.index) :
                      cidrsubnet(var.ipv6_cidr_block, var.ipv6_newbits, var.ipv6_netnum + count.index)}"
}
