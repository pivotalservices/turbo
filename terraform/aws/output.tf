output "domain_name_servers" {
  value = "${aws_route53_zone.bootstrap.name_servers}"
}

output "jumpbox_ip" {
  value = "${aws_instance.jumpbox.public_ip}"
}

output "jumpbox_dns" {
  value = "${aws_route53_record.jumpbox.name}.${var.dns_domain_name}"
}

output "concourse_url" {
  value = "https://${aws_route53_record.concourse.name}.${var.dns_domain_name}"
}

output "credhub_url" {
  value = "https://${aws_route53_record.credhub.name}.${var.dns_domain_name}"
}

output "uaa_url" {
  value = "https://${aws_route53_record.uaa.name}.${var.dns_domain_name}"
}
