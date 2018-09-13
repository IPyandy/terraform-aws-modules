output "vpc_ids" {
  value = "${coalescelist(aws_vpc.this.*.id, list(""))}"
}

output "vpc_id" {
  value = "${element(coalescelist(aws_vpc.this.*.id, list("")), 0)}"
}

output "subnet_ids" {
  value = "${
    map("public", "${coalescelist(aws_subnet.public.*.id, list(""))}",
        "private", "${coalescelist(aws_subnet.private.*.id, list(""))}"
        )}"
}

output "private_subnet_ids" {
  value = "${coalescelist(aws_subnet.private.*.id, list(""))}"
}

output "public_subnet_ids" {
  value = "${coalescelist(aws_subnet.public.*.id, list(""))}"
}

output "ipv6_cidr_blocks" {
  value = "${coalescelist(aws_vpc.this.*.ipv6_cidr_block, list(""))}"
}

output "ipv4_cidr_blocks" {
  value = "${coalescelist(aws_vpc.this.*.cidr_block, list(""))}"
}

#######################################
## VPC & OPTIONS
#######################################

output "dhcp_options_id" {
  value = "${local.dhcp_options_id}"
}

output "dhcp_options_association_id" {
  value = "${local.dhcp_options_association_id}"
}
