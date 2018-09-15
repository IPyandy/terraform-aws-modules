variable "create_subnet" {
  description = "Sometimes for testing or refreshing state, set to false to delete resources"
  default     = true
}

variable "vpc_id" {
  default = ""
}

variable "ipv4_subnets" {
  description = "Use when passing manual ipv4 subnets"
  default     = []
}

variable "num_subnets" {
  description = "Used if subnets <= 0 in value to count"
  default     = 0
}

variable "map_public" {
  default = false
}

variable "tags" {
  default = {}
}

variable "azs" {
  default = []
}

variable "ipv4_cidr_block" {
  description = "Used in cidrsubnet(cidrblock, newbits, netnum)"
  default     = ""
}

variable "ipv4_newbits" {
  description = "Used in cidrsubnet(cidrblock, newbits, netnum)"
  default     = 8
}

variable "ipv4_netnum" {
  description = "Used in cidrsubnet(cidrblock, newbits, netnum)"
  default     = 1
}

variable "ipv6_on_create" {
  default = true
}

variable "ipv6_newbits" {
  description = "Used in cidrsubnet(cidrblock, newbits, netnum)"
  default     = 8
}

variable "ipv6_netnum" {
  description = "Used in cidrsubnet(cidrblock, newbits, netnum)"
  default     = 1
}

variable "ipv6_cidr_block" {
  description = "Used in cidrsubnet(cidrblock, newbits, netnum)"

  # default value required for check expression to validate
  # otherwise an invalid cidrsubnet error is thrown
  default = ""
}

variable "ipv6_cidr_subnets" {
  description = "Used to manually pass a list of IPv6 subnets to assign."
  default     = []
}
