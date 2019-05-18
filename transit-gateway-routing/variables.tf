# Route Variables

variable "route_cidr_blocks" {
  description = "Transit Gateway route cidr block list"
  default     = []
}

variable "attachment_ids" {
  description = "List of VPC attachment IDs, even if only one, must be provided as list"
  default     = []
}

variable "route_table_ids" {
  description = "List of transit gateway route table ids"
  default     = []
}
