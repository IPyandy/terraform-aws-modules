variable "vpc_id" {
  default = ""
}

variable "is_public" {
  default = false
}

variable "num_nat_gws" {
  default = 0
}

variable "nat_gw_tags" {
  default = {}
}

variable "eip_tags" {
  default = {}
}

variable "inet_gw_tags" {
  default = {}
}

variable "pub_rt_tags" {
  default = {}
}

variable "priv_rt_tags" {
  default = {}
}

variable "ipv6_on" {
  default = true
}

variable "subnet_ids" {
  default = []
}
