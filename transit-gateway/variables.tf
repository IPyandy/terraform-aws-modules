# Transit Gateway Variables

variable "create_transit_gateway" {
  description = "Whether to create the transit gateway: default = true"
  default     = true
}

variable "transit_gateway_description" {
  description = "Description for the transit gateway"
  default     = "Transit Gateway"
}

variable "amazon_side_asn" {
  description = "The BGP ASN for the Amazon side of the connection: default = 64512"
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether to auto accept resource attachment requests"
  default     = "disable"
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table"
  default     = "enable"
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
  default     = "enable"
}

# This variable is shared between the transit gateway and VPC attachments
variable "dns_support" {
  description = "Whether DNS support is enabled: default = enable"
  default     = "enable"
}

variable "vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multipath is supported on VPN connections: default = enable"
  default     = "enable"
}

variable "transit_gateway_tags" {
  description = "Tags for the transit gateway"
  default     = {}
}

# VPC Attachment Variables

variable "vpc_ids" {
  description = "The VPC IDs to attache the to the transit gateway: default = []"
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach to the VPC, only one subnet per availability zone"
  default     = []
}

variable "ipv6_support" {
  description = "Whether IPv6 support is enabled: default = enable"
  default     = "enable"
}

variable "associate_default_route_table" {
  description = "Whether to associate the attachment to the default route table: default = true (boolean)"
  default     = true
}

variable "vpc_default_route_table_propagation" {
  description = "Whether to propagate routes with the transit gateways default route table: default = true (boolean)"
  default     = true
}

variable "vpc_attachment_tags" {
  description = "A list of tags for each attachment: default = []"
  default     = []
}
