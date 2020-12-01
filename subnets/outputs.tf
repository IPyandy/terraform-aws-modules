# DUAL STACK OUTPUTS
output "subnet_ids" {
  value = aws_subnet.this.*.id
}

output "subnet_id" {
  value = element(concat(aws_subnet.this.*.id, list("")), 0)
}

output "ipv4_subnets" {
  value = element(concat(aws_subnet.this.*.cidr_block, list("")), 0)
}

output "ipv4_subnet" {
  value = element(concat(aws_subnet.this.*.cidr_block, list("")), 0)
}

output "ipv6_subnet" {
  value = element(concat(aws_subnet.this.*.ipv6_cidr_block, list("")), 0)
}

output "ipv6_subnets" {
  value = element(concat(aws_subnet.this.*.ipv6_cidr_block, list("")), 0)
}

output "azs" {
  value = element(concat(aws_subnet.this.*.availability_zone, list("")), 0)
}

output "az" {
  value = element(concat(aws_subnet.this.*.availability_zone, list("")), 0)
}

output "arns" {
  value = element(concat(aws_subnet.this.*.arn, list("")), 0)
}

output "arn" {
  value = element(concat(aws_subnet.this.*.arn, list("")), 0)
}

output "vpc_ids" {
  value = element(concat(aws_subnet.this.*.vpc_id, list("")), 0)
}

output "vpc_id" {
  value = element(concat(aws_subnet.this.*.vpc_id, list("")), 0)
}
