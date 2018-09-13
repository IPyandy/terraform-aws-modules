resource "aws_lb_listener" "listener" {
  count             = "${var.create_tg && length(var.listener_ports) > 0 ? length(var.listener_ports) : 0}"
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "${var.listener_ports[0]}"
  protocol          = "${var.tg_protocol}"

  default_action {
    type             = "forward"
    target_group_arn = "${element(aws_lb_target_group.tg.*.arn, count.index)}"
  }
}

# TODO: CREATE ACME INTEGRATION FOR CERTIFICATES
# TODO: CREATE SECUIRE LISTENER
# TODO: LOOK AT MAPS POSSIBLY FOR VARIABLES
# CANNOT USE UNTIL VALID CERTIFICATE IS ASSIGNED
# resource "aws_lb_listener" "listener_secure" {
#   count             = "${var.create_tg && length(var.sec_listener_ports) > 0 ? length(var.listener_ports) : 0}"
#   load_balancer_arn = "${aws_lb.alb.arn}"
#   port              = "${var.sec_listener_portvar.sec_listener_ports[0]}"
#   protocol          = "${var.sec_tg_protocol}"
#   certificate_arn = ""
#   ssl_policy        = ""

#   default_action {
#     type             = "forward"
#     target_group_arn = "${element(aws_lb_target_group.tg_secure.*.arn, count.index)}"
#   }
# }

resource "aws_lb_listener_rule" "forward_listener_rule" {
  count        = "${var.create_tg && length(var.forward_rules) > 0 ? length(var.forward_rules) : 0}"
  listener_arn = "${element(aws_lb_listener.listener.*.arn, count.index)}"
  priority     = "${var.listener_rule_priority[count.index]}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_lb_target_group.tg.*.arn, count.index)}"
  }

  # Two conditions max
  condition {
    field  = "path-pattern"
    values = ["${var.forward_rules[count.index]}"]
  }

  condition {
    field  = "host-header"
    values = ["*${var.listener_domains[count.index]}"]
  }
}
