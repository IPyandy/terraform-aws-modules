output "vpc" {
  value = "${aws_vpc.this}"
}

output "private_subnet" {
  value = "${aws_subnet.private}"
}

output "public_subnets" {
  value = "${aws_subnet.public}"
}
