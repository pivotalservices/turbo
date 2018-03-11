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
  value = "https://${replace(google_dns_record_set.concourse-lb.name,"/\\.$/","")}"
}

output "credhub_url" {
  value = "https://${replace(google_dns_record_set.credhub-lb.name,"/\\.$/","")}"
}

output "uaa_url" {
  value = "https://${replace(google_dns_record_set.uaa-lb.name,"/\\.$/","")}"
}

output "metrics_url" {
  value = "${local.common_flags["metrics"] == "true" ? format("https://%s", replace(join("", google_dns_record_set.uaa-lb.*.name),"/\\.$/","")) : ""}"
}
