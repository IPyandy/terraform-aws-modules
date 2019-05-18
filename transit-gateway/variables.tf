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
