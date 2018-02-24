resource "google_dns_managed_zone" "bootstrap" {
  name        = "${var.env_name}-bootstrap-zone"
  dns_name    = "${var.dns_domain_name}."
  description = "Production DNS zone"
}
