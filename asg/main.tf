resource "aws_launch_template" "launch_tpl" {
  # count         = "${1 - var.create_alb}"
  name                   = "${var.asg_name}-launch-tpl"
  image_id               = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.ssh_key_name}"
  user_data              = "${base64encode(var.user_data)}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"

  iam_instance_profile {
    name = "${var.instance_profile}"
  }

  monitoring {
    enabled = "${var.enable_monitoring}"
  }

  block_device_mappings = ["${var.block_device_mappings}"]
  network_interfaces    = ["${var.network_interfaces}"]
  tag_specifications    = ["${var.tag_specifications}"]
  tags                  = "${var.lt_tags}"
}

## AUTOSCALING GROUP

resource "aws_autoscaling_group" "asg" {
  count                     = "${1 - var.create_alb}"
  desired_capacity          = "${var.asg_desired_capacity}"
  max_size                  = "${var.asg_max_size}"
  min_size                  = "${var.asg_min_size}"
  name                      = "${var.asg_name}-asg"
  vpc_zone_identifier       = ["${var.asg_subnets}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  launch_template {
    id      = "${aws_launch_template.launch_tpl.id}"
    version = "${var.launch_tpl_version}"
  }

  tags = ["${var.asg_tags}"]
}

resource "aws_autoscaling_group" "alb_asg" {
  count                     = "${var.create_alb}"
  desired_capacity          = "${var.asg_desired_capacity}"
  max_size                  = "${var.asg_max_size}"
  min_size                  = "${var.asg_min_size}"
  name                      = "${var.asg_name}-alb-asg"
  vpc_zone_identifier       = ["${var.asg_subnets}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  target_group_arns         = ["${var.target_groups}"]

  launch_template {
    id      = "${aws_launch_template.launch_tpl.id}"
    version = "${var.launch_tpl_version}"
  }

  tags = ["${var.asg_tags}"]
}

# SCALING POLICIES

# WITH ALB
resource "aws_autoscaling_policy" "alb_asg_policy" {
  count = "${var.create_alb}"
  name  = "${var.asg_name}-alb-asg-policy"

  # The policy type, either "SimpleScaling", "StepScaling" or "TargetTrackingScaling".
  # If this value isn't provided, AWS will default to "SimpleScaling."
  policy_type = "${var.asg_policy_type}"

  target_tracking_configuration = "${var.tracking_spec}"

  autoscaling_group_name = "${aws_autoscaling_group.alb_asg.name}"
}

# WITHOUT ALB
resource "aws_autoscaling_policy" "asg_policy" {
  count = "${1 - var.create_alb}"
  name  = "${var.asg_name}-asg-policy"

  # The policy type, either "SimpleScaling", "StepScaling" or "TargetTrackingScaling".
  # If this value isn't provided, AWS will default to "SimpleScaling."
  policy_type = "${var.asg_policy_type}"

  target_tracking_configuration = "${var.tracking_spec}"

  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
