# DUAL STACK OUTPUTS
output "subnet_ids" {
  value = "${aws_subnet.this.*.id}"
}

output "subnet_id" {
  value = "${element(aws_subnet.this.*.id, 0)}"
}

output "ipv4_subnets" {
  value = "${aws_subnet.this.*.cidr_block}"
}

output "ipv4_subnet" {
  value = "${element(aws_subnet.this.*.cidr_block, 0)}"
}

output "ipv6_subnet" {
  value = "${element(aws_subnet.this.*.ipv6_cidr_block, 0)}"
}

output "ipv6_subnets" {
  value = "${aws_subnet.this.*.ipv6_cidr_block}"
}

output "azs" {
  value = "${aws_subnet.this.*.availability_zone}"
}

output "az" {
  value = "${element(aws_subnet.this.*.availability_zone, 0)}"
}

output "arns" {
  value = "${aws_subnet.this.*.arn}"
}

output "arn" {
  value = "${element(aws_subnet.this.*.arn, 0)}"
}

output "vpc_ids" {
  value = "${aws_subnet.this.*.vpc_id}"
}

output "vpc_id" {
  value = "${element(aws_subnet.this.*.vpc_id, 0)}"
}
