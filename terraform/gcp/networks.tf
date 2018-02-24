resource "google_compute_network" "bootstrap" {
  name                    = "${var.env_name}-boostrap"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "jumpbox" {
  name          = "${var.env_name}-jumpbox"
  ip_cidr_range = "${cidrsubnet(var.bootstrap_subnet, 2, 0)}"
  network       = "${google_compute_network.bootstrap.self_link}"
  region        = "${var.gcp_region}"
}

resource "google_compute_subnetwork" "bosh" {
  name          = "${var.env_name}-bosh"
  ip_cidr_range = "${cidrsubnet(var.bootstrap_subnet, 2, 1)}"
  network       = "${google_compute_network.bootstrap.self_link}"
  region        = "${var.gcp_region}"
}

resource "google_compute_subnetwork" "concourse" {
  name          = "${var.env_name}-concourse"
  ip_cidr_range = "${cidrsubnet(var.bootstrap_subnet, 2, 2)}"
  network       = "${google_compute_network.bootstrap.self_link}"
  region        = "${var.gcp_region}"
}
