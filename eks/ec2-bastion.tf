resource "aws_instance" "bastion_ec2" {
  count                       = "${var.create_bastion_host ? 1 : 0}"
  ami                         = "${var.ec2_bastion_ami}"                                    # amazon linux AMI (us-east-1)
  instance_type               = "${var.bastion_instance_type}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  associate_public_ip_address = "true"
  subnet_id                   = "${var.pub_subnets[count.index]}"
  vpc_security_group_ids      = ["${aws_security_group.bastion_ec2_sg.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_instance_profile.name}"

  credit_specification {
    cpu_credits = "${var.bastion_cpu_credits}"
  }

  tags {
    Name = "Bastion Host-${var.env}-${var.rand1}"
    Use  = "Managing cluster: ${aws_eks_cluster.this.name}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bastion-setup.sh"
    destination = "/home/ec2-user/bastion-setup.sh"

    connection {
      type        = "ssh"
      agent       = "false"
      user        = "ec2-user"
      private_key = "${file(var.priv_key_path)}"
    }
  }

  provisioner "file" {
    source      = "${var.priv_key_path}"
    destination = "/home/ec2-user/.ssh/ssh-access-key"

    connection {
      type        = "ssh"
      agent       = "false"
      user        = "ec2-user"
      private_key = "${file(var.priv_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/",
      "chmod +x /home/ec2-user/bastion-setup.sh",
      "source /home/ec2-user/bastion-setup.sh",
      "chmod u-wx,og-rwx /home/ec2-user/.ssh/ssh-access-key",
    ]

    connection {
      type        = "ssh"
      agent       = "false"
      user        = "ec2-user"
      private_key = "${file(var.priv_key_path)}"
    }
  }

  depends_on = [
    "aws_eks_cluster.this",
  ]
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.key_name}-${var.env}-${var.rand1}-ssh-key"
  public_key = "${file(var.key_path)}"
}
