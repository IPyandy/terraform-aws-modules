variable rand1 {
  default = 0
}

variable "vpc_id" {
  default = ""
}

variable "pub_subnets" {
  default = []
}

variable "priv_subnets" {
  default = []
}

variable "cluster_name" {
  default = "aws_eks_cluster"
}

variable "eks_version" {
  default = "1.11"
}

variable "node_instance_type" {
  default = "m5.large"
}

variable "create_bastion_host" {
  default = true
}

variable "bastion_instance_type" {
  default = "t3.micro"
}

variable "bastion_cpu_credits" {
  default = "standard"
}

variable "ec2_bastion_ami" {
  default = ""
}

variable "ext_pc_cidr" {
  default = ""
}

variable "env" {
  default = "dev"
}

variable "key_path" {
  default = ""
}

variable "priv_key_path" {
  default = ""
}

variable "key_name" {
  default = ""
}

variable "domain_name" {
  default = ""
}

variable "create_dns" {
  default = false
}

variable "cnames" {
  default = []
}

variable "create_alb" {
  default = false
}

variable "target_groups" {
  default = []
}

variable "alb_dns_name" {
  default = ""
}
