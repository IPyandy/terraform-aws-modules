variable "create_asg" {
  default = false
}

variable "asg_name" {
  default = "asg_name"
}

variable "create_default_sg" {
  default = false
}

variable "vpc_id" {
  default = ""
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
