variable "asg_name" {
  default = "asg_name"
}

variable "ami_id" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

variable "instance_profile" {
  default = ""
}

variable "enable_monitoring" {
  default = false
}

variable "user_data" {
  default = ""
}

variable "block_device_mappings" {
  default = []
}

variable "network_interfaces" {
  default = []
}

variable "tag_specifications" {
  default = []
}

variable "create_alb" {
  default = false
}

variable "asg_desired_capacity" {
  default = 0
}

variable "asg_max_size" {
  default = 0
}

variable "asg_min_size" {
  default = 0
}

variable "asg_subnets" {
  default = []
}

variable "health_check_grace_period" {
  default = 30
}

variable "health_check_type" {
  description = "health_check_type options are EC2 or ELB"
  default     = "EC2"
}

variable "target_groups" {
  default = []
}

variable "launch_tpl_version" {
  default = "$Latest"
}

variable "asg_tags" {
  default = []
}

variable "lt_tags" {
  default = {}
}

variable "asg_policy_type" {
  default = "TargetTrackingScaling"
}

variable "tracking_spec" {
  default = []
}

variable "security_group_ids" {
  default = []
}
