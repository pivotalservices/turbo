#### Concourse Web LB
resource "google_compute_ssl_certificate" "concourse_web" {
  name_prefix = "bootstrap-certificate-"
  description = "${var.env_name} - Bootstrap Concourse Certificate"
  private_key = "${tls_private_key.ssl_private_key.private_key_pem}"
  certificate = "${tls_locally_signed_cert.ssl_cert.cert_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_address" "concourse_web_lb" {
  name = "${var.env_name}-concourse-web-lb"
}

resource "google_dns_record_set" "concourse-lb" {
  name = "ci.${google_dns_managed_zone.bootstrap.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.bootstrap.name}"

  rrdatas = ["${google_compute_global_address.concourse_web_lb.address}"]
}

resource "google_compute_instance_group" "concourse_web_lb" {
  name = "${var.env_name}-concourse-web-lb"
  zone = "${element(var.gcp_zones, count.index)}"

  named_port {
    name = "https"
    port = 443
  }

  named_port {
    name = "http"
    port = 80
  }

  count = "${length(var.gcp_zones)}"
}

## HTTPS
resource "google_compute_https_health_check" "concourse_web_https_hc" {
  name = "${var.env_name}-concourse-https-public"

  port                = 443
  request_path        = "/"
  check_interval_sec  = 5
  timeout_sec         = 4
  healthy_threshold   = 3
  unhealthy_threshold = 3
}

### Credhub/UAA
resource "google_dns_record_set" "credhub-lb" {
  name = "credhub.${google_dns_managed_zone.bootstrap.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.bootstrap.name}"

  rrdatas = ["${google_compute_global_address.concourse_web_lb.address}"]
}

resource "google_dns_record_set" "uaa-lb" {
  name = "uaa.${google_dns_managed_zone.bootstrap.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.bootstrap.name}"

  rrdatas = ["${google_compute_global_address.concourse_web_lb.address}"]
}

# Credhub
resource "google_compute_instance_group" "credhub_lb" {
  name = "${var.env_name}-credhub-lb"
  zone = "${element(var.gcp_zones, count.index)}"

  named_port {
    name = "credhub"
    port = 8844
  }

  named_port {
    name = "uaa"
    port = 8443
  }

  count = "${length(var.gcp_zones)}"
}

resource "google_compute_https_health_check" "credhub_https_hc" {
  name = "${var.env_name}-credhub-https-public"

  port                = 8844
  request_path        = "/health"
  check_interval_sec  = 5
  timeout_sec         = 4
  healthy_threshold   = 3
  unhealthy_threshold = 3
}

# UAA
resource "google_compute_https_health_check" "uaa_https_hc" {
  name = "${var.env_name}-uaa-https-public"

  port                = 8443
  request_path        = "/healthz"
  check_interval_sec  = 5
  timeout_sec         = 4
  healthy_threshold   = 3
  unhealthy_threshold = 3
}
