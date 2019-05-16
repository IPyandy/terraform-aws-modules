data "aws_availability_zones" "azs" {}

################################################################################
## VPC & OPTIONS
################################################################################

resource "aws_vpc" "this" {
  count                            = var.create_vpc ? 1 : 0
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classic_link
  enable_classiclink_dns_support   = var.enable_classic_link_dns_support
  assign_generated_ipv6_cidr_block = false
  tags                             = var.vpc_tags
}

resource "aws_vpc_dhcp_options" "this" {
  count                = var.create_vpc && var.create_dhcp_options ? 1 : 0
  domain_name          = var.dhcp_domain_name
  domain_name_servers  = var.dhcp_domain_name_servers
  ntp_servers          = var.dhcp_ntp_servers
  netbios_name_servers = var.dhcp_netbios_name_servers
  netbios_node_type    = var.dhcp_netbios_node_type
  tags                 = var.dhcp_option_tags
}

resource "aws_vpc_dhcp_options_association" "this" {
  count           = var.create_vpc && var.create_dhcp_options ? 1 : 0
  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[count.index].id
}

################################################################################
## SUBNETS
################################################################################

resource "aws_subnet" "public" {
  count                           = var.num_pub_subnets
  vpc_id                          = aws_vpc.this[0].id
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = var.map_public
  assign_ipv6_address_on_creation = false
  tags                            = var.pub_subnet_tags
  cidr_block                      = cidrsubnet(aws_vpc.this[0].cidr_block, var.ipv4_pub_newbits, var.ipv4_pub_netnum + count.index)
}

resource "aws_subnet" "private" {
  count                           = var.num_priv_subnets
  vpc_id                          = aws_vpc.this[0].id
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = var.priv_subnet_tags

  cidr_block = cidrsubnet(aws_vpc.this[0].cidr_block,
    var.ipv4_priv_newbits,
    var.ipv4_priv_netnum +
  count.index)
}

################################################################################
### ROUTING AND INTERNET
################################################################################

### INTERNET GATEWAY
resource "aws_internet_gateway" "this" {
  count  = var.create_inet_gw ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = var.inet_gw_tags
}

### NAT GATEWAY and EIPS
resource "aws_eip" "natgw_ip" {
  count = var.num_nat_gws
  vpc   = "true"
  tags  = var.eip_tags
}

resource "aws_nat_gateway" "nat_gw" {
  count = var.num_nat_gws

  depends_on    = [aws_internet_gateway.this]
  allocation_id = aws_eip.natgw_ip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = var.nat_gw_tags
}

### ROUTE TABLES
resource "aws_route_table" "public" {
  count  = var.num_pub_subnets
  vpc_id = aws_vpc.this[0].id
  tags   = var.pub_rt_tags
}

resource "aws_route" "pub_default_v4" {
  count = var.num_pub_subnets

  depends_on             = [aws_internet_gateway.this]
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public_association" {
  count          = var.num_pub_subnets
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public[count.index].id
}

### PRIVATE TABLE
resource "aws_route_table" "private" {
  count  = var.num_priv_subnets
  vpc_id = aws_vpc.this[0].id
  tags   = var.priv_rt_tags
}

resource "aws_route" "priv_default_v4" {
  count                  = var.num_nat_gws
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
}

resource "aws_route_table_association" "private_association" {
  count          = var.num_priv_subnets
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

################################################################################
### FLOW LOGS
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_flow_log ? 1 : 0
  name  = var.flow_log_group_name
}

resource "aws_cloudwatch_log_stream" "this" {
  count          = var.create_flow_log ? 1 : 0
  name           = "${var.flow_log_group_name}-stream"
  log_group_name = aws_cloudwatch_log_group.this[0].name
}


resource "aws_flow_log" "this" {
  count           = var.create_flow_log ? 1 : 0
  log_destination = aws_cloudwatch_log_group.this[count.index].arn
  iam_role_arn    = aws_iam_role.flow_role[count.index].arn
  vpc_id          = aws_vpc.this[0].id
  traffic_type    = "ALL"
}

resource "aws_iam_role" "flow_role" {
  count = var.create_flow_log ? 1 : 0
  name  = "flow_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_policy" {
  count = var.create_flow_log ? 1 : 0
  name = "vpc_flow_policy"
  role = aws_iam_role.flow_role[count.index].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
