resource "google_compute_backend_service" "concourse_web_lb_https_backend_service_2az" {
  name        = "${var.env_name}-concourse-https-lb-backend-2az"
  port_name   = "https"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group                 = "${google_compute_instance_group.concourse_web_lb.0.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  backend {
    group                 = "${google_compute_instance_group.concourse_web_lb.1.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  health_checks = ["${google_compute_https_health_check.concourse_web_https_hc.self_link}"]

  count = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}

resource "google_compute_backend_service" "credhub_lb_https_backend_service_2az" {
  name        = "${var.env_name}-credhub-https-lb-backend-2az"
  port_name   = "credhub"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group                 = "${google_compute_instance_group.credhub_lb.0.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  backend {
    group                 = "${google_compute_instance_group.credhub_lb.1.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  health_checks = ["${google_compute_https_health_check.credhub_https_hc.self_link}"]

  count = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}

resource "google_compute_backend_service" "uaa_lb_https_backend_service_2az" {
  name        = "${var.env_name}-uaa-https-lb-backend-2az"
  port_name   = "uaa"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group                 = "${google_compute_instance_group.credhub_lb.0.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  backend {
    group                 = "${google_compute_instance_group.credhub_lb.1.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  health_checks = ["${google_compute_https_health_check.uaa_https_hc.self_link}"]

  count = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}

resource "google_compute_backend_service" "metrics_lb_https_backend_service_2az" {
  name        = "${var.env_name}-metrics-https-lb-backend-2az"
  port_name   = "grafana"
  protocol    = "HTTPS"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    group                 = "${google_compute_instance_group.metrics_lb.0.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  backend {
    group                 = "${google_compute_instance_group.metrics_lb.1.self_link}"
    balancing_mode        = "RATE"
    max_rate_per_instance = "10000"
  }

  health_checks = ["${google_compute_https_health_check.metrics_https_hc.self_link}"]

  count = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}

resource "google_compute_url_map" "concourse_web_https_lb_url_map_2az" {
  name = "${var.env_name}-concourse-web-https-2az"

  default_service = "${google_compute_backend_service.concourse_web_lb_https_backend_service_2az.self_link}"

  host_rule {
    hosts        = ["credhub.${var.dns_domain_name}"]
    path_matcher = "credhub"
  }

  path_matcher {
    name = "credhub"

    default_service = "${google_compute_backend_service.credhub_lb_https_backend_service_2az.self_link}"
  }

  host_rule {
    hosts        = ["uaa.${var.dns_domain_name}"]
    path_matcher = "uaa"
  }

  path_matcher {
    name = "uaa"

    default_service = "${google_compute_backend_service.uaa_lb_https_backend_service_2az.self_link}"
  }

  host_rule {
    hosts        = ["metrics.${var.dns_domain_name}"]
    path_matcher = "metrics"
  }

  path_matcher {
    name = "metrics"

    default_service = "${google_compute_backend_service.metrics_lb_https_backend_service_2az.self_link}"
  }

  count = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}

resource "google_compute_target_https_proxy" "concourse_web_https_lb_proxy_2az" {
  name             = "${var.env_name}-concourse-web-https-proxy-2az"
  description      = "Load balancing front end https"
  url_map          = "${google_compute_url_map.concourse_web_https_lb_url_map_2az.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.concourse_web.self_link}"]
  count            = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}

resource "google_compute_global_forwarding_rule" "concourse_web_https_2az" {
  name       = "${var.env_name}-concourse-web-lb-https-2az"
  ip_address = "${google_compute_global_address.concourse_web_lb.address}"
  target     = "${google_compute_target_https_proxy.concourse_web_https_lb_proxy_2az.self_link}"
  port_range = "443"
  count      = "${length(var.gcp_zones) == 2 ? 1 : 0}"
}