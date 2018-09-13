# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

data "template_file" "eks_node_init" {
  template = "${file("${path.module}/scripts/eks-node-bootstrap.tpl")}"

  vars {
    MAX_PODS         = "${lookup(local.max_pod_per_node, var.node_instance_type)}"
    CLUSTER_CERT     = "${aws_eks_cluster.this.certificate_authority.0.data}"
    CLUSTER_ENDPOINT = "${aws_eks_cluster.this.endpoint}"
    CLUSTER_ID       = "${aws_eks_cluster.this.id}"
  }
}

# Find latest standard EKS optimized image
data "aws_ami" "eks-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon account ID
}

# Find latest GPU EKS optimized image
data "aws_ami" "eks-gpu-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node*"]
  }

  most_recent = true
  owners      = ["aws-marketplace"] # Amazon owner alias
}
