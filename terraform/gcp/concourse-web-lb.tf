#### Root CA
resource "tls_private_key" "rootca_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "rootca_cert" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.rootca_private_key.private_key_pem}"

  validity_period_hours = 87600
  early_renewal_hours   = 8760

  is_ca_certificate = true

  allowed_uses = ["cert_signing"]

  subject {
    common_name         = "Test"
    organization        = "Test"
    organizational_unit = "Test"
    locality            = "Test"
    country             = "Test"
  }
}

#### Certificate
resource "tls_cert_request" "ssl_csr" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ssl_private_key.private_key_pem}"

  dns_names = [
    "*.${var.dns_domain_name}",
  ]

  subject {
    common_name         = "${var.dns_domain_name}"
    organization        = "Test"
    organizational_unit = "Test"
    locality            = "Test"
    country             = "Test"
  }
}

resource "tls_locally_signed_cert" "ssl_cert" {
  cert_request_pem   = "${tls_cert_request.ssl_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.rootca_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.rootca_cert.cert_pem}"

  validity_period_hours = 87600 # 2 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "ssl_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "google_compute_ssl_certificate" "concourse_web" {
  name_prefix = "bootstrap-certificate-"
  description = "${var.env_name} - Bootstrap Concourse Certificate"
  private_key = "${tls_private_key.ssl_private_key.private_key_pem}"
  certificate = "${tls_locally_signed_cert.ssl_cert.cert_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

#### Concourse Web LB
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
  zone = "${var.gcp_zone_1}"

  named_port {
    name = "https"
    port = 443
  }

  named_port {
    name = "http"
    port = 80
  }
}

## HTTPS
resource "google_compute_backend_service" "concourse_web_lb_https_backend_service" {
  name        = "${var.env_name}-concourse-https-lb-backend"
  port_name   = "https"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group.concourse_web_lb.self_link}"
  }

  health_checks = ["${google_compute_https_health_check.concourse_web_https_hc.self_link}"]
}

resource "google_compute_https_health_check" "concourse_web_https_hc" {
  name = "${var.env_name}-concourse-https-public"

  port                = 443
  request_path        = "/"
  check_interval_sec  = 5
  timeout_sec         = 3
  healthy_threshold   = 6
  unhealthy_threshold = 3
}

resource "google_compute_url_map" "concourse_web_https_lb_url_map" {
  name            = "${var.env_name}-concourse-web-https"
  default_service = "${google_compute_backend_service.concourse_web_lb_https_backend_service.self_link}"

  host_rule {
    hosts        = ["credhub.${var.dns_domain_name}"]
    path_matcher = "credhub"
  }

  path_matcher {
    name            = "credhub"
    default_service = "${google_compute_backend_service.credhub_lb_https_backend_service.self_link}"
  }

  host_rule {
    hosts        = ["uaa.${var.dns_domain_name}"]
    path_matcher = "uaa"
  }

  path_matcher {
    name            = "uaa"
    default_service = "${google_compute_backend_service.uaa_lb_https_backend_service.self_link}"
  }
}

resource "google_compute_target_https_proxy" "concourse_web_https_lb_proxy" {
  name             = "${var.env_name}-concourse-web-https-proxy"
  description      = "Load balancing front end https"
  url_map          = "${google_compute_url_map.concourse_web_https_lb_url_map.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.concourse_web.self_link}"]
}

resource "google_compute_global_forwarding_rule" "concourse_web_https" {
  name       = "${var.env_name}-concourse-web-lb-https"
  ip_address = "${google_compute_global_address.concourse_web_lb.address}"
  target     = "${google_compute_target_https_proxy.concourse_web_https_lb_proxy.self_link}"
  port_range = "443"
}

## HTTP
resource "google_compute_target_http_proxy" "concourse_web_http_lb_proxy" {
  name        = "${var.env_name}-concourse-web-http-proxy"
  description = "Load balancing front end http"
  url_map     = "${google_compute_url_map.concourse_web_https_lb_url_map.self_link}"
}

resource "google_compute_global_forwarding_rule" "concourse_web_http" {
  name       = "${var.env_name}-concourse-web-lb-http"
  ip_address = "${google_compute_global_address.concourse_web_lb.address}"
  target     = "${google_compute_target_http_proxy.concourse_web_http_lb_proxy.self_link}"
  port_range = "80"
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
  zone = "${var.gcp_zone_1}"

  named_port {
    name = "credhub"
    port = 8844
  }

  named_port {
    name = "uaa"
    port = 8443
  }
}

resource "google_compute_backend_service" "credhub_lb_https_backend_service" {
  name        = "${var.env_name}-credhub-https-lb-backend"
  port_name   = "credhub"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group.credhub_lb.self_link}"
  }

  health_checks = ["${google_compute_https_health_check.credhub_https_hc.self_link}"]
}

resource "google_compute_https_health_check" "credhub_https_hc" {
  name = "${var.env_name}-credhub-https-public"

  port                = 8844
  request_path        = "/health"
  check_interval_sec  = 5
  timeout_sec         = 3
  healthy_threshold   = 6
  unhealthy_threshold = 3
}

# UAA
resource "google_compute_backend_service" "uaa_lb_https_backend_service" {
  name        = "${var.env_name}-uaa-https-lb-backend"
  port_name   = "uaa"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group.credhub_lb.self_link}"
  }

  health_checks = ["${google_compute_https_health_check.uaa_https_hc.self_link}"]
}

resource "google_compute_https_health_check" "uaa_https_hc" {
  name = "${var.env_name}-uaa-https-public"

  port                = 8443
  request_path        = "/healthz"
  check_interval_sec  = 5
  timeout_sec         = 3
  healthy_threshold   = 6
  unhealthy_threshold = 3
}
