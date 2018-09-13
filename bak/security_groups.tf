### MASTER SECURITY GROUPS
resource "aws_security_group" "eks_master_sg" {
  name        = "${var.cluster_name}-${var.env}-${var.rand1}-master-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-master-sg"
  }
}

resource "aws_security_group_rule" "eks_allow_master_out" {
  description       = "Allow master outbound communication"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.eks_master_sg.id}"
  type              = "egress"
}

resource "aws_security_group_rule" "eks_allow_master_in" {
  description       = "Allow workstation to communicate with the cluster API Server"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks_master_sg.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks_pods_to_master_rule" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_master_sg.id}"
  source_security_group_id = "${aws_security_group.eks_node_sg.id}"
  to_port                  = 443
  type                     = "ingress"
}

### WORKER SECURITY GROUPS

resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-${var.env}-${var.rand1}-worker-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}-worker-sg-${var.rand1}",
     "kubernetes.io/cluster/${var.cluster_name}-${var.env}-${var.rand1}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "eks_allow_node_out" {
  description       = "Allow master outbound communication"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.eks_node_sg.id}"
  type              = "egress"
}

resource "aws_security_group_rule" "eks_node_self_rule" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_node_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_node_master_rule" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_master_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  description              = "Allows SSH access from the bastion host to the worker nodes"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.eks_node_sg.id}"
  source_security_group_id = "${aws_security_group.bastion_ec2_sg.id}"
}

resource "aws_security_group_rule" "allow_traffic_from_alb" {
  count                    = "${var.create_alb}"
  description              = "Allow traffic only from ALB if created"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.eks_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_alb_sg.id}"
}

# Bastion Security Groups

resource "aws_security_group" "bastion_ec2_sg" {
  name        = "${var.cluster_name}-${var.env}-${var.rand1}-bastion-sg"
  description = "Security Group te allow EC2 administer cluster and all things"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["137.103.55.195/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-bastion-sg"
  }
}

# ALB Security Groups

resource "aws_security_group" "eks_alb_sg" {
  count       = "${var.create_alb}"
  name        = "${var.cluster_name}-${var.env}-${var.rand1}-alb-sg"
  description = "ALB Security group for access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster_name}-${var.env}-${var.rand1}-alb-sg"
  }
}
