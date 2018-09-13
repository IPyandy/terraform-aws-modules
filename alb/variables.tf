variable "create_alb" {
  default = false
}

variable "alb_name" {
  default = "0"
}

variable "is_internal" {
  default = false
}

variable "is_application" {
  default = true
}

variable "enable_delete_protect" {
  default = false
}

variable "num_albs" {
  default = 0
}

variable "security_group_ids" {
  type    = "list"
  default = []
}

variable "subnet_ids" {
  type    = "list"
  default = []
}

variable "env" {
  default = ""
}

variable "rand1" {
  default = 0
}

variable "create_tg" {
  default = false
}

variable "vpc_id" {
  default = ""
}

variable "alb_arn" {
  default = ""
}

variable "sec_tg_ports" {
  type    = "list"
  default = []
}

variable "tg_ports" {
  type    = "list"
  default = []
}

variable "tg_protocol" {
  default = ""
}

variable "sec_tg_protocol" {
  default = ""
}

variable "health_interval" {
  default = "10"
}

variable "health_timeout" {
  default = "5"
}

variable "healthy_threshold" {
  default = "3"
}

variable "unhealthy_threshold" {
  default = "3"
}

variable "health_check_ports" {
  default = []
}

variable "matcher" {
  default = ""
}

variable "health_check_path" {
  default = []
}

variable "sec_health_interval" {
  default = "10"
}

variable "sec_health_timeout" {
  default = "5"
}

variable "sec_healthy_threshold" {
  default = "3"
}

variable "sec_unhealthy_threshold" {
  default = "3"
}

variable "sec_health_check_ports" {
  default = []
}

variable "sec_matcher" {
  default = ""
}

variable "sec_health_check_path" {
  default = []
}

variable "listener_ports" {
  default = []
}

variable "listener_rule_priority" {
  default = []
}

variable "forward_rules" {
  default = []
}

variable "sec_listener_rule_priority" {
  default = []
}

variable "sec_forward_rules" {
  default = []
}

variable "sec_listener_ports" {
  default = []
}

variable "listener_domains" {
  default = []
}
