resource "aws_launch_template" "this" {
  count                  = "${var.create_asg ? 1 : 0}"
  name                   = "${var.asg_name}-launch-tpl"
  image_id               = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.ssh_key_name}"
  user_data              = "${base64encode(var.user_data)}"
  vpc_security_group_ids = "${length(var.security_group_ids) > 0 ? var.security_group_ids : aws_security_group.this[*].id}"

  iam_instance_profile {
    name = "${var.instance_profile}"
  }

  monitoring {
    enabled = "${var.enable_monitoring}"
  }
}

## AUTOSCALING GROUP

resource "aws_autoscaling_group" "this" {
  count                     = "${var.create_asg ? 1 : 0}"
  desired_capacity          = "${var.asg_desired_capacity}"
  max_size                  = "${var.asg_max_size}"
  min_size                  = "${var.asg_min_size}"
  name                      = "${var.asg_name}-asg"
  vpc_zone_identifier       = "${var.asg_subnets}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  launch_template {
    id      = "${aws_launch_template.this[0].id}"
    version = "${var.launch_tpl_version}"
  }

}

# SCALING POLICIES

resource "aws_autoscaling_policy" "this" {
  count                  = "${var.create_asg ? 1 : 0}"
  name                   = "${var.asg_name}-asg-policy"
  policy_type            = "${var.asg_policy_type}"
  autoscaling_group_name = "${aws_autoscaling_group.this[0].name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

## DEFAULT SECURITY GROUP

resource "aws_security_group" "this" {
  count       = "${var.create_default_sg ? 1 : 0}"
  description = "Default security group for ${var.asg_name}"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
