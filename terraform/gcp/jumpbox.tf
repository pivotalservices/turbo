resource "google_compute_address" "jumpbox" {
  name = "${var.env_name}-jumpbox"
}

resource "google_dns_record_set" "jumpbox" {
  name = "jumpbox.${google_dns_managed_zone.bootstrap.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.bootstrap.name}"

  rrdatas = ["${google_compute_instance.jumpbox.network_interface.0.access_config.0.assigned_nat_ip}"]
}

resource "google_compute_instance" "jumpbox" {
  name         = "${var.env_name}-jumpbox"
  machine_type = "${var.jumpbox_server_type}"
  zone         = "${var.gcp_zone_1}"

  tags = ["${var.env_name}-jumpbox", "${var.env_name}-allow-ssh", "${var.env_name}-internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  // Local SSD disk
  scratch_disk {}

  network_interface {
    subnetwork = "${google_compute_subnetwork.jumpbox.name}"

    access_config {
      nat_ip = "${google_compute_address.jumpbox.address}"
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-delete-all.sh",
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-delete-all.sh",
    ]

    when = "destroy"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  # Used to destroy the jumpbox
  depends_on = [
    "google_compute_firewall.allow-ssh",
    "google_compute_firewall.internal-all",
    "google_compute_subnetwork.bosh",
    "google_compute_subnetwork.concourse",
    "google_compute_instance.nat-gateway-pri",
    "google_compute_route.nat-primary",
  ]
}
