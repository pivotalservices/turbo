output "domain_name_servers" {
  value = "${google_dns_managed_zone.bootstrap.name_servers}"
}

output "jumpbox_ip" {
  value = "${google_compute_address.jumpbox.address}"
}

output "jumpbox_dns" {
  value = "${google_dns_record_set.jumpbox.name}"
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
