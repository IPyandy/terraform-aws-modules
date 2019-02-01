### MASTER CLUSTER

resource "aws_eks_cluster" "this" {
  name     = "${var.cluster_name}-${var.env}-${var.rand1}"
  role_arn = "${aws_iam_role.eks_master_role.arn}"
  version  = "${var.eks_version}"

  vpc_config {
    # vpc_id             = "${aws_vpc.eks_vpc.id}" # can't be set?
    security_group_ids = ["${aws_security_group.eks_master_sg.id}"]
    subnet_ids         = ["${var.pub_subnets}", "${var.priv_subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_master_policy_attach",
    "aws_iam_role_policy_attachment.eks_master_policy_attach_service",
  ]
}
