output "domain_name_servers" {
  value = "${aws_route53_zone.bootstrap.name_servers}"
}

output "jumpbox_ip" {
  value = "${aws_eip.jumpbox.public_ip}"
}

output "jumpbox_dns" {
  value = "${aws_route53_record.jumpbox.name}.${var.dns_domain_name}"
}

output "concourse_url" {
  value = "${local.concourse_url}"
}

output "credhub_url" {
  value = "${local.credhub_url}"
}

output "uaa_url" {
  value = "${local.uaa_url}"
}

output "metrics_url" {
  value = "${local.metrics_url}"
}
