# Specific for credhub until concourse's team update credhub-cli to the latest version

resource "google_dns_record_set" "credhub-lb" {
  name = "credhub.${google_dns_managed_zone.bootstrap.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.bootstrap.name}"

  rrdatas = ["${google_compute_forwarding_rule.credhub_fr.ip_address}"]
}

resource "google_compute_forwarding_rule" "credhub_fr" {
  name                  = "${var.env_name}-credhub-lb"
  target                = "${google_compute_target_pool.credhub_tp.self_link}"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "8844"
}

resource "google_compute_target_pool" "credhub_tp" {
  name = "${var.env_name}-credhub"
}
