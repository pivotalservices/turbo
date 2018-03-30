data "aws_route53_zone" "main_zone" {
  name = "${var.master_dns_domain_name}"
}

resource "aws_route53_zone" "bootstrap" {
  name = "${var.dns_domain_name}"
}

resource "aws_route53_record" "bootstrap_ns" {
  zone_id = "${data.aws_route53_zone.main_zone.zone_id}"
  name    = "${var.dns_domain_name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.bootstrap.name_servers.0}",
    "${aws_route53_zone.bootstrap.name_servers.1}",
    "${aws_route53_zone.bootstrap.name_servers.2}",
    "${aws_route53_zone.bootstrap.name_servers.3}",
  ]
}

resource "aws_route53_record" "bootstrap_self_ns" {
  zone_id = "${aws_route53_zone.bootstrap.zone_id}"
  name    = "${var.dns_domain_name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.bootstrap.name_servers.0}",
    "${aws_route53_zone.bootstrap.name_servers.1}",
    "${aws_route53_zone.bootstrap.name_servers.2}",
    "${aws_route53_zone.bootstrap.name_servers.3}",
  ]
}

resource "aws_route53_record" "jumpbox" {
  zone_id = "${aws_route53_zone.bootstrap.zone_id}"
  name    = "jumpbox"
  type    = "A"
  ttl     = "30"

  records = ["${aws_eip.jumpbox.public_ip}"]
}

resource "aws_route53_record" "credhub" {
  zone_id = "${aws_route53_zone.bootstrap.zone_id}"
  name    = "credhub"
  type    = "A"

  alias {
    name                   = "${aws_lb.ucc_lb.dns_name}"
    zone_id                = "${aws_lb.ucc_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "uaa" {
  zone_id = "${aws_route53_zone.bootstrap.zone_id}"
  name    = "uaa"
  type    = "A"

  alias {
    name                   = "${aws_lb.ucc_lb.dns_name}"
    zone_id                = "${aws_lb.ucc_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "concourse" {
  zone_id = "${aws_route53_zone.bootstrap.zone_id}"
  name    = "ci"
  type    = "A"

  alias {
    name                   = "${aws_lb.ucc_lb.dns_name}"
    zone_id                = "${aws_lb.ucc_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "metrics" {
  zone_id = "${aws_route53_zone.bootstrap.zone_id}"
  name    = "metrics"
  type    = "A"

  alias {
    name                   = "${aws_lb.ucc_lb.dns_name}"
    zone_id                = "${aws_lb.ucc_lb.zone_id}"
    evaluate_target_health = true
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}
