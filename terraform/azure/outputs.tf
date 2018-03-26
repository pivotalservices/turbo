output "domain_name_servers" {
  value = "${azurerm_dns_zone.turbo.name_servers}"
}

output "jumpbox_ip" {
  value = "${azurerm_public_ip.jumpbox.ip_address}"
}

output "jumpbox_dns" {
  value = "${azurerm_dns_a_record.jumpbox.name}.${var.dns_domain_name}"
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
