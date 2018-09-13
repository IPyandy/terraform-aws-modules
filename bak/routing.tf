### INTERNET GATEWAY
resource "aws_internet_gateway" "eks_inet_gateway" {
  count  = "${var.create_inetgw}"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-inet-gateway"
  }
}

## NAT GATEWAY and EIPS

resource "aws_eip" "eks_natgw_ip" {
  count = "${var.create_natgw >= 1 && length(var.private_subnets) >= 0 ? 1 : 0}"
  vpc   = "true"

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-natgw-eip"
  }
}

resource "aws_nat_gateway" "k8s-natgw" {
  count         = "${var.create_natgw >= 1 && length(var.private_subnets) >= 0 ? 1 : 0}"
  allocation_id = "${aws_eip.eks_natgw_ip.*.id[count.index]}"
  subnet_id     = "${aws_subnet.eks_public_subnets.*.id[count.index]}"

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-nat-gateway"
  }
}

### ROUTE TABLES
## PUBLIC TABLE
resource "aws_route_table" "eks_public_rt" {
  count  = "${var.create_inetgw >= 1 && length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks_inet_gateway.id}"
  }

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-public-route-table"
  }
}

## PRIVATE TABLE
### NOT Current used
resource "aws_route_table" "eks_private_rt" {
  count  = "${var.create_natgw >= 1 && length(var.private_subnets) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.eks_vpc.id}"
  count  = "${length(var.private_subnets)}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.k8s-natgw.*.id[count.index]}"
  }

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-private-route-table"
  }
}

### ROUTE TABLE ASSOCATIONS
resource "aws_route_table_association" "public_rt_association" {
  count = "${var.create_inetgw >= 1 && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${aws_subnet.eks_public_subnets.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks_public_rt.id}"
}

### NOT Current used
resource "aws_route_table_association" "private_rt_association" {
  count = "${var.create_natgw >= 1 && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${aws_subnet.eks_private_subnets.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

### ROUTE TABLES - NO GATEWAYS
## PUBLIC TABLE
resource "aws_route_table" "eks_public_rt-nogw" {
  count  = "${var.create_inetgw <= 0 && length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.eks_vpc.id}"

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-public-route-table"
  }
}

## PRIVATE TABLE - NO GATEWAYS
### NOT Current used
resource "aws_route_table" "eks_private_rt-nogw" {
  count  = "${var.create_natgw <= 0 && length(var.private_subnets) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.eks_vpc.id}"
  count  = "${length(var.private_subnets)}"

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-private-route-table"
  }
}

### ROUTE TABLE ASSOCATIONS
resource "aws_route_table_association" "public_rt_association-nogw" {
  count = "${var.create_inetgw <= 0 && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${aws_subnet.eks_public_subnets.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks_public_rt-nogw.id}"
}

### NOT Current used
resource "aws_route_table_association" "private_rt_association-nogw" {
  count = "${var.create_natgw <= 0 && length(var.private_subnets) > length(var.private_subnets) ? 1 : 0}"

  subnet_id      = "${aws_subnet.eks_private_subnets.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks_private_rt-nogw.id}"
}
