resource "google_dns_managed_zone" "bootstrap" {
  name        = "${var.env_name}-bootstrap-zone"
  dns_name    = "${var.dns_domain_name}."
  description = "Production DNS zone"
}

resource "google_dns_record_set" "subdomain_ns" {
  name = "${google_dns_managed_zone.bootstrap.dns_name}"
  type = "NS"
  ttl  = 300

  managed_zone = "${var.master_dns_zone_name}"

  rrdatas = ["${google_dns_managed_zone.bootstrap.name_servers}"]
}
