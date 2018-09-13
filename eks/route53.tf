data "aws_route53_zone" "main" {
  count        = "${var.create_dns ? 1 : 0}"
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "bastion-cname" {
  count   = "${var.create_dns ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "bastion.${var.env}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.bastion_ec2.public_dns}"]
}

resource "aws_route53_record" "alb-cname" {
  count   = "${var.create_dns && var.create_alb && length(var.cnames) > 0 ? length(var.cnames) : 0}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.cnames[count.index]}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.alb_dns_name}"]
}
