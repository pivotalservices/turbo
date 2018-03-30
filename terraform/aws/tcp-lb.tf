### Credhub
resource "aws_security_group" "ucc-lb" {
  name        = "${var.env_name}-ucc-lb"
  description = "${var.env_name} ucc LB"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-ucc-lb"
    turbo = "${var.env_name}"
  }
}

resource "aws_security_group_rule" "concourse_https_in" {
  security_group_id = "${aws_security_group.ucc-lb.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  cidr_blocks = [
    "${var.source_admin_networks}",
    "${formatlist("%s/32", aws_eip.bosh_natgw.*.public_ip)}",
    "${formatlist("%s/32", aws_eip.jumpbox.*.public_ip)}",
  ]
}

resource "aws_security_group_rule" "credhub_https_in" {
  security_group_id = "${aws_security_group.ucc-lb.id}"
  type              = "ingress"
  from_port         = 8844
  to_port           = 8844
  protocol          = "tcp"

  cidr_blocks = [
    "${var.source_admin_networks}",
    "${formatlist("%s/32", aws_eip.bosh_natgw.*.public_ip)}",
    "${formatlist("%s/32", aws_eip.jumpbox.*.public_ip)}",
  ]
}

resource "aws_security_group_rule" "uaa_https_in" {
  security_group_id = "${aws_security_group.ucc-lb.id}"
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"

  cidr_blocks = [
    "${var.source_admin_networks}",
    "${formatlist("%s/32", aws_eip.bosh_natgw.*.public_ip)}",
    "${formatlist("%s/32", aws_eip.jumpbox.*.public_ip)}",
  ]
}

resource "aws_security_group_rule" "all_out" {
  security_group_id = "${aws_security_group.ucc-lb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "ucc_lb" {
  name            = "${var.env_name}-ucc-lb"
  internal        = false
  security_groups = ["${aws_security_group.ucc-lb.id}"]
  subnets         = ["${aws_subnet.jumpbox.*.id}"]

  tags {
    Name  = "${var.env_name}-ucc-lb"
    turbo = "${var.env_name}"
  }
}

# Concourse
resource "aws_lb_target_group" "concourse" {
  name     = "${var.env_name}-concourse-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.bootstrap.id}"

  health_check {
    protocol            = "TCP"
    port                = "443"
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-concourse-tg"
    turbo = "${var.env_name}"
  }
}

resource "aws_lb_listener" "concourse" {
  load_balancer_arn = "${aws_lb.ucc_lb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.concourse.arn}"
    type             = "forward"
  }
}

# Credhub
resource "aws_lb_target_group" "credhub" {
  name     = "${var.env_name}-credhub-tg"
  port     = 8844
  protocol = "TCP"
  vpc_id   = "${aws_vpc.bootstrap.id}"

  health_check {
    protocol            = "HTTPS"
    port                = "8844"
    path                = "/health"
    timeout             = 4
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-credhub-tg"
    turbo = "${var.env_name}"
  }
}

resource "aws_lb_listener" "credhub" {
  load_balancer_arn = "${aws_lb.ucc_lb.arn}"
  port              = "8844"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.credhub.arn}"
    type             = "forward"
  }
}

# UAA
resource "aws_lb_target_group" "uaa" {
  name     = "${var.env_name}-uaa-tg"
  port     = 8443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.bootstrap.id}"

  health_check {
    protocol            = "HTTPS"
    port                = "8443"
    path                = "/healthz"
    timeout             = 4
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-uaa-tg"
    turbo = "${var.env_name}"
  }
}

resource "aws_lb_listener" "uaa" {
  load_balancer_arn = "${aws_lb.ucc_lb.arn}"
  port              = "8443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.uaa.arn}"
    type             = "forward"
  }
}

# Metrics
resource "aws_lb_target_group" "metrics" {
  name     = "${var.env_name}-metrics-tg"
  port     = 3000
  protocol = "TCP"
  vpc_id   = "${aws_vpc.bootstrap.id}"

  health_check {
    protocol            = "TCP"
    port                = "3000"
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-metrics-tg"
    turbo = "${var.env_name}"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "aws_lb_listener" "metrics" {
  load_balancer_arn = "${aws_lb.ucc_lb.arn}"
  port              = "3000"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.metrics.arn}"
    type             = "forward"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "aws_security_group_rule" "metrics_https_in" {
  security_group_id = "${aws_security_group.ucc-lb.id}"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"

  cidr_blocks = [
    "${var.source_admin_networks}",
    "${formatlist("%s/32", aws_eip.bosh_natgw.*.public_ip)}",
    "${formatlist("%s/32", aws_eip.jumpbox.*.public_ip)}",
  ]

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}
