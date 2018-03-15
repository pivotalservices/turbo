resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.env_name}-allow-ssh"
  network = "${google_compute_network.bootstrap.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_admin_networks}"
  target_tags   = ["${var.env_name}-allow-ssh"]
}

resource "google_compute_firewall" "internal-all" {
  name    = "${var.env_name}-allow-internal-all"
  network = "${google_compute_network.bootstrap.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  target_tags = ["${var.env_name}-internal"]
  source_tags = ["${var.env_name}-internal"]
}

resource "google_compute_firewall" "concourse_web" {
  name    = "${var.env_name}-allow-http-web"
  network = "${google_compute_network.bootstrap.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["${var.source_admin_networks}", "130.211.0.0/22", "35.191.0.0/16", "${google_compute_address.jumpbox.address}/32"]
  target_tags   = ["${var.env_name}-ucc-web"]
}

resource "google_compute_firewall" "credhub" {
  name    = "${var.env_name}-allow-credhub"
  network = "${google_compute_network.bootstrap.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = ["${var.source_admin_networks}", "130.211.0.0/22", "35.191.0.0/16", "${google_compute_address.jumpbox.address}/32"]
  target_tags   = ["${var.env_name}-ucc-credhub-uaa"]
}

resource "google_compute_firewall" "uaa" {
  name    = "${var.env_name}-allow-uaa"
  network = "${google_compute_network.bootstrap.name}"

  allow {
    protocol = "tcp"
    ports    = ["8844"]
  }

  source_ranges = ["${var.source_admin_networks}", "130.211.0.0/22", "35.191.0.0/16", "${google_compute_address.jumpbox.address}/32"]
  target_tags   = ["${var.env_name}-ucc-credhub-uaa"]
}

resource "google_compute_firewall" "metrics" {
  name    = "${var.env_name}-allow-metrics"
  network = "${google_compute_network.bootstrap.name}"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["${var.source_admin_networks}", "130.211.0.0/22", "35.191.0.0/16", "${google_compute_address.jumpbox.address}/32"]
  target_tags   = ["${var.env_name}-ucc-metrics"]

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}
