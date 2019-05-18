resource "aws_lb_target_group" "tg" {
  count  = "${var.create_tg && length(var.health_check_path) > 0 ? length(var.health_check_path) : 0}"
  vpc_id = "${var.vpc_id}"

  # Lots of name constraints for targer name
  # 1-32 characters long
  # only alphanumeric and hyphens (-) allowed
  name = "alb-tg-${var.tg_ports[0]}-${count.index}"

  port     = "${element(var.tg_ports, count.index)}"
  protocol = "${var.tg_protocol}"

  health_check {
    path                = "${var.health_check_path[count.index]}"
    port                = "${var.health_check_ports[count.index]}"
    protocol            = "${var.tg_protocol}"
    interval            = "${var.health_interval}"
    timeout             = "${var.health_timeout}"
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    matcher             = "${var.matcher}"
  }

  stickiness {
    type            = "lb_cookie" # default
    cookie_duration = "86400"     # default
    enabled         = false       # defaul
  }
}

resource "aws_lb_target_group" "tg_secure" {
  count  = "${var.create_tg && length(var.sec_health_check_path) > 0 ? length(var.sec_health_check_path) : 0}"
  vpc_id = "${var.vpc_id}"

  # Lots of name constraints for targer name
  # 1-32 characters long
  # only alphanumeric and hyphens (-) allowed
  name = "alb-tg-secure-${var.sec_tg_ports[0]}-${count.index}"

  port     = "${element(var.sec_tg_ports, count.index)}"
  protocol = "${var.sec_tg_protocol}"

  health_check {
    path                = "${var.sec_health_check_path[count.index]}"
    port                = "${var.sec_health_check_ports[count.index]}"
    protocol            = "${var.sec_tg_protocol}"
    interval            = "${var.sec_health_interval}"
    timeout             = "${var.sec_health_timeout}"
    healthy_threshold   = "${var.sec_healthy_threshold}"
    unhealthy_threshold = "${var.sec_unhealthy_threshold}"
    matcher             = "${var.sec_matcher}"
  }

  stickiness {
    type            = "lb_cookie" # default
    cookie_duration = "86400"     # default
    enabled         = false       # defaul
  }
}

resource "random_id" "alg_random" {
  byte_length = 2
}
