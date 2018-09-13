# VPC
resource "aws_vpc" "eks_vpc" {
  count                = "${var.create_vpc ? 1 : 0}"
  cidr_block           = "${var.cidr_block}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${
    map(
      "Name", "${var.cluster_name}-${var.env}-${var.rand1}-vpc",
      "kubernetes.io/cluster/${var.cluster_name}-${var.env}-${var.rand1}", "shared",
    )
  }"
}

# PUBLIC SUBNETS
resource "aws_subnet" "eks_public_subnets" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  vpc_id     = "${aws_vpc.eks_vpc.id}"
  cidr_block = "${var.public_subnets[count.index]}"

  availability_zone       = "${element(data.aws_availability_zones.azs.names, count.index+1)}"
  map_public_ip_on_launch = "${var.public_ip_on_launch}"

  tags = "${
    map(
      "Name", "${var.cluster_name}-${var.env}-${var.rand1}-pub-subnet-${var.rand1}-${var.public_subnets[count.index]}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.env}-${var.rand1}", "shared",
    )
  }"
}

# PRIVATE SUBNETS
resource "aws_subnet" "eks_private_subnets" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id     = "${aws_vpc.eks_vpc.id}"
  cidr_block = "${var.private_subnets[count.index]}"

  availability_zone       = "${element(data.aws_availability_zones.azs.names, count.index+1)}"
  map_public_ip_on_launch = false

  tags = "${
    map(
      "Name", "${var.cluster_name}-${var.env}-${var.rand1}-priv-subnet-${var.rand1}-${var.private_subnets[count.index]}",
      "kubernetes.io/cluster/${var.cluster_name}-${var.env}-${var.rand1}", "shared",
      "kubernetes.io/role/internal-elb", "1",
    )
  }"
}
