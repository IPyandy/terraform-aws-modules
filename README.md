This is a work in progress and I'm creating my own version of `terraform` modules. I know there's a public registry. Though this way I learn more along the way. I'm splitting individual parts into separate modules as they become necessary.

I plan to cover all `terraform resources` and `data sources` for this.

## EKS Sample

Below is an example of using some of these modules to deploy and `EKS` cluster. Even within this sample, there are pieces that will become their own modules. I'm using EKS to get the first modules out of the way.

### Working EKS Sample

The [code](examples/eks)

```hcl
terraform {
  required_version = ">= 0.11.0"

  ##############################################
  ## SAMPLE S3 BACKEND FOR PRODUCTION
  ## BACKENDS CANNOT CONTAIN INTERPOLATION AS
  ## OF TODAY, WILL UPDATE IF THAT CHANGES
  ##############################################
  # backend "s3" {
  #   bucket  = "{BUCKET-NAME}"
  #   key     = "terraform/{PREFIX}/{PREFIX-SUB-PATH}/{ENV}/{PROJECT-NAME}/terraform.tfstate"
  #   profile = "{AWS-PROFILE}"
  #   region  = "{REGION}"
  #   encrypt = "true"
  # }
  ##############################################
}

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "${var.credentials}"
  profile                 = "${var.profile}"
  version                 = ">= 1.36.0"
}

### RANDOMNESS AND VARIABLES
resource "random_id" "rand1" {
  byte_length = 2
}

resource "random_id" "rand2" {
  byte_length = 4
}

locals {
  rand1        = "${random_id.rand1.dec}"
  cluster_name = "eks-cluster"
  env          = "dev"
}

### EKS
module "eks" {
  source = "../../eks/"

  # source = "git::ssh://git@gitlab.com/IPyandy/terraform-cloud-modules.git//aws/eks?ref=v0.0.2"

  vpc_id                = "${module.vpc.vpc_id}"
  pub_subnets           = "${module.vpc.public_subnet_ids}"     # method #1
  priv_subnets          = "${module.vpc.subnet_ids["private"]}" # method #2
  create_dns            = true
  create_alb            = true
  cluster_name          = "${local.cluster_name}"
  env                   = "${local.env}"
  domain_name           = "${var.domain_name}"
  alb_dns_name          = "${module.alb.alb_dns_name}"
  cnames                = ["ghost", "bookinfo"]
  key_path              = "${var.key_path}"
  priv_key_path         = "${var.priv_key_path}"
  key_name              = "eks-ssh-key"
  node_instance_type    = "m5.large"
  bastion_instance_type = "t3.micro"
  ec2_bastion_ami       = "ami-04681a1dbd79675a5"
  bastion_cpu_credits   = "unlimited"
  ext_pc_cidr           = "${var.ext_pc_cidr}"
  rand1                 = "${local.rand1}"
}

### VPC
module "vpc" {
  source = "../../vpc/"

  ### VPC
  create_vpc = true

  azs = [
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
  ]

  cidr_block                      = "10.0.0.0/16"
  instance_tenancy                = "default"
  enable_dns_hostnames            = true
  enable_dns_support              = true
  enable_classic_link             = false
  enable_classic_link_dns_support = false

  ### DHCP OPTIONS
  create_dhcp_options      = true
  dhcp_domain_name         = "yandy.cloud"
  dhcp_domain_name_servers = ["AmazonProvidedDNS"]

  dhcp_ntp_servers = [
    "69.195.159.158",
    "173.255.206.153",
  ]

  dhcp_netbios_name_servers = []
  dhcp_netbios_node_type    = 2

  ### SUBNETS
  map_public = false

  pub_subnets = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  priv_subnets = [
    "10.0.128.0/24",
    "10.0.129.0/24",
    "10.0.130.0/24",
  ]

  ### IPV6
  # ipv6_cidr_subnets = [
  #   "2600:1f18:63e8:5f60::/64",
  #   "2600:1f18:63e8:5f61::/64",
  #   "2600:1f18:63e8:5f62::/64",
  # ]

  ### ROUTING AND INTERNET
  create_nat_gw      = true
  num_nat_gws        = 1
  create_ipv6_egress = true

  ### ALL TAGS

  vpc_tags = "${map("Name", "${local.cluster_name}-${local.env}-${local.rand1}-vpc",
        "kubernetes.io/cluster/${local.cluster_name}-${local.env}-${local.rand1}", "shared")}"
  pub_subnet_tags = "${map("Name", "${local.cluster_name}-${local.env}-${local.rand1}-public",
        "kubernetes.io/cluster/${local.cluster_name}-${local.env}-${local.rand1}", "shared")}"
  priv_subnet_tags = [
    {
      "Name" = "${
        local.cluster_name}-${local.env}-${local.rand1}}-private"

      "kubernetes.io/cluster/${local.cluster_name}-${local.env}-${local.rand1}" = "shared"
      "kubernetes.io/role/internal-elb"                                         = "1"
    },
  ]
  inet_gw_tags = [
    {
      Name = "${local.cluster_name}-${local.env}-${local.rand1}-inet-gateway"
    },
  ]
  pub_rt_tags = [
    {
      Name = "${local.cluster_name}-${local.env}-${local.rand1}-public-table"
    },
  ]
  eip_tags = [
    {
      Name = "${local.cluster_name}-${local.env}-${local.rand1}-natgw-eip"
    },
  ]
  nat_gw_tags = [
    {
      Name = "${local.cluster_name}-${local.env}-${local.rand1}-nat-gateway"
    },
  ]
  priv_rt_tags = [
    {
      Name = "${local.cluster_name}-${local.env}-${local.rand1}-private-table"
    },
  ]
}

### EXTRA SUBNETS (THEY DON'T DO ANYTHING NOW)
module "subnets" {
  source        = "../../subnets/"
  create_subnet = true

  # ipv4_subnets = [
  #   "10.0.64.0/24",
  #   "10.0.65.0/24",
  #   "10.0.66.0/24",
  # ]

  num_subnets     = 3
  vpc_id          = "${module.vpc.vpc_id}"
  ipv4_cidr_block = "${module.vpc.ipv4_cidr_blocks[0]}" # can be set manually
  ipv4_newbits    = 8
  ipv4_netnum     = 16
  map_public      = false

  # ipv6_cidr_subnets = [
  #   "2600:1f18:63e8:5f60::/64",
  #   "2600:1f18:63e8:5f61::/64",
  #   "2600:1f18:63e8:5f62::/64",
  # ]

  ipv6_cidr_block = "${module.vpc.ipv6_cidr_blocks[0]}" # can be set manually
  ipv6_newbits    = 8
  ipv6_netnum     = 64
  ipv6_on_create  = false
  tags = [
    {
      Name    = "${local.cluster_name}-${local.env}-${local.rand1}--extra-table"
      purpose = "Just testing the subnet module"
    },
  ]
}

### NODE AUTOSCALING GRUP AND LAUNCH TEMPLATE
module "asg" {
  source = "../../asg/"

  # LAUNCH TEMPLATE
  asg_name          = "${local.cluster_name}-${local.env}-${local.rand1}"
  instance_type     = "m5.large"
  ami_id            = "${module.eks.eks-node}"
  ssh_key_name      = "${module.eks.ssh_key_name}"
  instance_profile  = "${module.eks.node_instance_profile}"
  enable_monitoring = true
  user_data         = "${module.eks.node_user_data}"

  block_device_mappings = [
    {
      ebs = [
        {
          volume_size           = "100"
          volume_type           = "gp2"
          delete_on_termination = true
          encrypted             = false
        },
      ]

      device_name = "/dev/xvdb"
    },
  ]

  network_interfaces = [
    {
      associate_public_ip_address = false
      delete_on_termination       = true
      device_index                = "0"
      security_groups             = ["${module.eks.node_sg}"]
    },
  ]

  tag_specifications = [
    {
      resource_type = "instance"

      tags {
        Name = "${local.cluster_name}-${local.env}-${local.rand1}-launch-tpl"
      }
    },
  ]

  # AUTOSCALING GROUP
  launch_tpl_version        = "$Latest"
  asg_desired_capacity      = 3
  asg_max_size              = 6
  asg_min_size              = 3
  asg_subnets               = ["${module.vpc.subnet_ids["private"]}"]
  health_check_grace_period = 30
  health_check_type         = "EC2"
  create_alb                = true
  target_groups             = "${concat("${module.alb.tg}","${module.alb.tg_secure}")}"

  tags = [
    {
      key                 = "Name"
      value               = "${local.cluster_name}-${local.env}-${local.rand1}-alb-node-asg"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${local.cluster_name}-${local.env}-${local.rand1}"
      value               = "owned"
      propagate_at_launch = true
    },
  ]

  # AUTOSCALING GROUP POLICY
  # Only supported TargetTrackingScaling as of right now
  asg_policy_type = "TargetTrackingScaling"

  tracking_spec = [
    {
      predefined_metric_specification = [
        {
          predefined_metric_type = "ASGAverageCPUUtilization"
        },
      ]

      target_value = 60.0
    },
  ]
}

### DEPLOY ALB TO USE AS INGRESS POINT
### REQUIRES TERRAFORM AS KUBERNETES
### HAS NO OFFICIAL SUPPORT FOR ALB
module "alb" {
  source = "../../alb/"

  # ALB
  create_alb            = true
  is_application        = true
  is_internal           = false
  enable_delete_protect = false
  alb_name              = "eks-cluster"
  env                   = "dev"
  rand1                 = "${local.rand1}"
  num_albs              = 1
  security_group_ids    = "${module.eks.alb_security_group_ids}"
  subnet_ids            = "${module.vpc.subnet_ids["public"]}"

  # TARGET GROUPS - FOR ISTIO
  create_tg               = true
  vpc_id                  = "${module.vpc.vpc_id}"
  tg_ports                = ["31380", "31381"]
  sec_tg_ports            = ["31390", "31391"]
  health_check_ports      = ["traffic-port", "31368"]
  sec_health_check_ports  = ["traffic-port", "31368"]
  tg_protocol             = "HTTP"
  sec_tg_protocol         = "HTTPS"
  health_interval         = "10"
  health_timeout          = "5"
  healthy_threshold       = "3"
  unhealthy_threshold     = "3"
  health_check_path       = ["/productpage", "/"]
  matcher                 = "200-299"
  sec_health_interval     = "10"
  sec_health_timeout      = "5"
  sec_healthy_threshold   = "3"
  sec_unhealthy_threshold = "3"
  sec_health_check_path   = ["/productpage", "/"]
  sec_matcher             = "200-299"

  # LISTENERS
  listener_domains           = ["${var.cnames[0]}.${var.domain_name}", "${var.cnames[1]}.${var.domain_name}"]
  listener_rule_priority     = ["100", "101"]
  forward_rules              = ["/productpage/*", "/*"]
  listener_ports             = ["80"]
  sec_listener_rule_priority = ["100", "101"]
  sec_forward_rules          = ["/productpage/*", "/*"]
  sec_listener_ports         = ["443"]
}
```
