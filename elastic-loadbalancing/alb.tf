resource "aws_lb" "alb" {
  count              = "${var.is_application && var.num_albs > 0 ? var.num_albs : 0}"
  name               = "${var.alb_name}-${var.env}-${var.rand1}-alb-${count.index}"
  internal           = "${var.is_internal}"
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_ids}"]
  subnets            = ["${var.subnet_ids}"]
  enable_http2       = true

  enable_deletion_protection = "${var.enable_delete_protect}"

  # access_logs {
  #   bucket  = "${aws_s3_bucket.logs_bucket.bucket}"
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags {
    Environment = "${var.env}"
    Name        = "${var.alb_name}-${var.env}-${var.rand1}-alb-${count.index}"
  }
}
