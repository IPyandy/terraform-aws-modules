output "alb_dns_name" {
  # value = "${var.create_alb ? element(aws_lb.alb.*.dns_name, 0) : ""}"
  value = "${element(concat(aws_lb.alb.*.dns_name, list("")), 0)}"
}

output "alb_arn" {
  value = "${element(aws_lb.alb.*.arn, 0)}"
}

output "tg" {
  value = ["${aws_lb_target_group.tg.*.arn}"]
}

output "tg_secure" {
  value = ["${aws_lb_target_group.tg_secure.*.arn}"]
}
