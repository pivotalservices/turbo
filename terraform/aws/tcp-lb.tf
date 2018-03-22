### Credhub
resource "aws_security_group" "credhub-elb" {
  name        = "${var.env_name}-inbound-credhub"
  description = "${var.env_name} Inbound credhub"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-Inbound credhub"
    turbo = "${var.env_name}"
  }
}

resource "aws_security_group_rule" "credhub_https_in" {
  security_group_id = "${aws_security_group.credhub-elb.id}"
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

resource "aws_security_group_rule" "credhub_all_out" {
  security_group_id = "${aws_security_group.credhub-elb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_elb" "credhub-elb" {
  name            = "credhub-elb"
  subnets         = ["${aws_subnet.jumpbox.*.id}"]
  security_groups = ["${aws_security_group.credhub-elb.id}"]
  internal        = false

  // The time in seconds that the connection is allowed to be idle
  idle_timeout = 300

  listener {
    instance_port     = 8844
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  health_check {
    target = "HTTPS:8844/health"

    timeout             = 4
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-credhub-elb"
    turbo = "${var.env_name}"
  }
}

### UAA
resource "aws_security_group" "uaa-elb" {
  name        = "${var.env_name}-inbound-uaa"
  description = "${var.env_name} Inbound uaa"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-Inbound uaa"
    turbo = "${var.env_name}"
  }
}

resource "aws_security_group_rule" "uaa_https_in" {
  security_group_id = "${aws_security_group.uaa-elb.id}"
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

resource "aws_security_group_rule" "uaa_all_out" {
  security_group_id = "${aws_security_group.uaa-elb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_elb" "uaa-elb" {
  name            = "uaa-elb"
  subnets         = ["${aws_subnet.jumpbox.*.id}"]
  security_groups = ["${aws_security_group.uaa-elb.id}"]
  internal        = false

  // The time in seconds that the connection is allowed to be idle
  idle_timeout = 300

  listener {
    instance_port     = 8443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  health_check {
    target              = "HTTPS:8443/healthz"
    timeout             = 4
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-uaa-elb"
    turbo = "${var.env_name}"
  }
}

### Concourse
resource "aws_security_group" "concourse-elb" {
  name        = "${var.env_name}-inbound-concourse"
  description = "${var.env_name} Inbound concourse"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-Inbound concourse"
    turbo = "${var.env_name}"
  }
}

resource "aws_security_group_rule" "concourse_https_in" {
  security_group_id = "${aws_security_group.concourse-elb.id}"
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

resource "aws_security_group_rule" "concourse_all_out" {
  security_group_id = "${aws_security_group.concourse-elb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_elb" "concourse-elb" {
  name            = "concourse-elb"
  subnets         = ["${aws_subnet.jumpbox.*.id}"]
  security_groups = ["${aws_security_group.concourse-elb.id}"]
  internal        = false

  // The time in seconds that the connection is allowed to be idle
  idle_timeout = 300

  listener {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  health_check {
    target              = "HTTPS:443/health"
    timeout             = 4
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-concourse-elb"
    turbo = "${var.env_name}"
  }
}

# metrics (grafana)
resource "aws_security_group" "metrics-elb" {
  name        = "${var.env_name}-inbound-metrics"
  description = "${var.env_name} Inbound metrics"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-Inbound metrics"
    turbo = "${var.env_name}"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "aws_security_group_rule" "metrics_https_in" {
  security_group_id = "${aws_security_group.metrics-elb.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  cidr_blocks = [
    "${var.source_admin_networks}",
    "${formatlist("%s/32", aws_eip.bosh_natgw.*.public_ip)}",
    "${formatlist("%s/32", aws_eip.jumpbox.*.public_ip)}",
  ]

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "aws_security_group_rule" "metrics_all_out" {
  security_group_id = "${aws_security_group.metrics-elb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "aws_elb" "metrics-elb" {
  name            = "metrics-elb"
  subnets         = ["${aws_subnet.jumpbox.*.id}"]
  security_groups = ["${aws_security_group.metrics-elb.id}"]
  internal        = false

  // The time in seconds that the connection is allowed to be idle
  idle_timeout = 300

  listener {
    instance_port     = 3000
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  health_check {
    target              = "TCP:3000"
    timeout             = 4
    interval            = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags {
    Name  = "${var.env_name}-metrics-elb"
    turbo = "${var.env_name}"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}
