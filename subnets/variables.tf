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
  description = "Used to auto calculate ipv4 subnets using cidrsubnet() from a given block"
  default     = ""
}

variable "ipv4_newbits" {
  default = 8
}

variable "ipv4_netnum" {
  default = 1
}

variable "ipv6_on_create" {
  default = true
}

variable "ipv6_newbits" {
  description = "This will take the place of newbits in the cidrsubnet(iprange, newbits, netnum) function"
  default     = 8
}

variable "ipv6_netnum" {
  description = "This will take the place of netnum and use count.index in the cidrsubnet(iprange, newbits, netnum+count.index) function"
  default     = 1
}

variable "ipv6_cidr_block" {
  description = "Used to auto calculate ipv6 subnets using cidrsubnet() from a given block"

  # default value required for check expression to validate
  # otherwise an invalid cidrsubnet error is thrown
  default = ""
}

variable "ipv6_cidr_subnets" {
  description = "Used to manually pass a list of IPv6 subnets to assign."
  default     = []
}
