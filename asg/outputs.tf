output "user_data" {
  value = "${aws_launch_template.this[*].user_data}"
}

output "asg" {
  value = "${aws_autoscaling_group.this}"
}

output "security_group_ids" {
  value = "${aws_security_group.this[*].id}"
}
