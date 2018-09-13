# DUAL STACK OUTPUTS
output "subnet_ids" {
  value = "${aws_subnet.this.*.id}"
}

output "subnet_id" {
  value = "${aws_subnet.this.*.id}"
}

output "ipv4_subnets" {
  value = "${aws_subnet.this.*.cidr_block}"
}

output "ipv4_subnet" {
  value = "${aws_subnet.this.*.cidr_block}"
}

output "ipv6_subnets" {
  value = "${aws_subnet.this.*.ipv6_cidr_block}"
}

output "ipv6_subnet" {
  value = "${aws_subnet.this.*.ipv6_cidr_block}"
}

output "azs" {
  value = "${aws_subnet.this.*.availability_zone}"
}

output "az" {
  value = "${aws_subnet.this.*.availability_zone}"
}

output "arns" {
  value = "${aws_subnet.this.*.arn}"
}

output "arn" {
  value = "${aws_subnet.this.*.arn}"
}

output "vpc_ids" {
  value = "${aws_subnet.this.*.vpc_id}"
}

output "vpc_id" {
  value = "${aws_subnet.this.*.vpc_id}"
}
