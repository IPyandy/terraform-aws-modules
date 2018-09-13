output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "aws-auth" {
  value = "${local.aws-auth}"
}

output "eks-name" {
  value = "${local.eks-cluster-name}"
}

output "aws_env" {
  value = "${local.aws_env}"
}

output "aws_bastion_pub_ip" {
  value = "${aws_instance.bastion_ec2.*.public_ip}"
}

output "alb_security_group_ids" {
  value = ["${aws_security_group.eks_alb_sg.*.id}"]
}

output "ssh_key_name" {
  value = "${aws_key_pair.ssh_key.key_name}"
}

output "node_instance_profile" {
  value = "${aws_iam_instance_profile.eks_node_instance_profile.name}"
}

output "node_user_data" {
  value = "${local.node_user_data}"
}

output "node_sg" {
  value = "${aws_security_group.eks_node_sg.id}"
}

output "eks-node" {
  value = "${data.aws_ami.eks-node.image_id}"
}

output "eks-gpu-node" {
  value = "${data.aws_ami.eks-gpu-node.image_id}"
}
