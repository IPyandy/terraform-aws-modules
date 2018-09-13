### INTERNET GATEWAY
resource "aws_internet_gateway" "inet_gateway" {
  count  = "${var.is_public}"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.inet_gw_tags}"
}

resource "aws_egress_only_internet_gateway" "ipv6_gateway" {
  count  = "${var.ipv6_on >= 1 && var.is_public <= 0 ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
}

## NAT GATEWAY and EIPS

resource "aws_eip" "natgw_ip" {
  count = "${var.is_public <= 0 && var.num_nat_gws >= 1 && length(var.subnet_ids) >= 1 ? var.num_nat_gws : 0}"
  vpc   = "true"
  tags  = "${var.eip_tags}"
}

resource "aws_nat_gateway" "nat_gw" {
  count         = "${var.is_public <= 0 && var.num_nat_gws >= 1 && length(var.subnet_ids) >= 1 ? var.num_nat_gws : 0}"
  allocation_id = "${aws_eip.natgw_ip.*.id[count.index]}"
  subnet_id     = "${var.subnet_ids[count.index]}"
  tags          = "${var.nat_gw_tags}"
}

### ROUTE TABLES
## PUBLIC TABLE
resource "aws_route_table" "public" {
  count  = "${length(var.subnet_ids) >= 1 ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.pub_rt_tags}"
}

resource "aws_route" "pub_default_v4" {
  count                  = "${var.is_public ? 1 : 0}"
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.inet_gateway.id}"
}

resource "aws_route" "pub_default_ipv6" {
  count                       = "${var.is_public >= 1 && var.ipv6_on >= 1 ? 1 : 0}"
  route_table_id              = "${aws_route_table.public.*.id}"
  destination_ipv6_cidr_block = "0.0.0.0/0"
  gateway_id                  = "${aws_internet_gateway.inet_gateway.id}"
}

resource "aws_route_table_association" "public_association" {
  count          = "${var.is_public >= 1 && length(var.subnet_ids) >= 1 ? length(var.subnet_ids) : 0}"
  subnet_id      = "${var.subnet_ids[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

## PRIVATE TABLE
resource "aws_route_table" "private" {
  count  = "${var.is_public <= 0 && length(var.subnet_ids) >= 1 ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  count  = "${length(var.subnet_ids)}"
  tags   = "${var.priv_rt_tags}"
}

resource "aws_route" "priv_default_v4" {
  count                  = "${var.is_public <= 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}

resource "aws_route" "priv_default_ipv6" {
  count                       = "${var.is_public <= 0 && var.ipv6_on >= 1 ? 1 : 0}"
  route_table_id              = "${aws_route_table.private.*.id}"
  destination_ipv6_cidr_block = "0.0.0.0/0"
  egress_only_gateway_id      = "${aws_egress_only_internet_gateway.ipv6_gateway.id}"
}

resource "aws_route_table_association" "private_association" {
  count          = "${var.is_public <= 0 && length(var.subnet_ids) >= 1 ? length(var.subnet_ids) : 0}"
  subnet_id      = "${var.subnet_ids[count.index]}"
  route_table_id = "${aws_route_table.private.id}"
}
