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

resource "google_compute_disk" "jumpbox_data" {
  name = "${var.env_name}-jumpbox-data"
  type = "pd-standard"
  size = "10"
  zone = "${element(var.gcp_zones,0)}"
}

resource "google_compute_instance" "jumpbox" {
  name         = "${var.env_name}-jumpbox"
  machine_type = "${var.jumpbox_server_type}"
  zone         = "${element(var.gcp_zones,0)}"

  tags = ["${var.env_name}-jumpbox", "${var.env_name}-allow-ssh", "${var.env_name}-internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  attached_disk {
    source      = "${google_compute_disk.jumpbox_data.self_link}"
    device_name = "data"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.jumpbox.name}"

    access_config {
      nat_ip = "${local.ssh_host}"
    }
  }

  metadata_startup_script = <<EOF
  #!/usr/bin/env bash
while [ ! -e /dev/disk/by-id/google-data ]; do sleep 1; done
if ! sudo file -sL /dev/disk/by-id/google-data-part1 | grep ext4; then
    echo -e "g\nn\np\n1\n\n\nw" | sudo fdisk /dev/disk/by-id/google-data
    sleep 10
    sudo mkfs.ext4 /dev/disk/by-id/google-data-part1
fi
sudo mkdir /data
sudo mount /dev/disk/by-id/google-data-part1 /data
if ! grep $(hostname) /etc/hosts; then
  echo "127.0.1.1" $(hostname) >> /etc/hosts
fi
EOF

  metadata {
    sshKeys = "${var.ssh_user}:${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
  }
}

resource "null_resource" "destroy-all" {
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/automation/bosh/scripts/generic/bosh-delete-all.sh",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/bosh/scripts/generic/bosh-delete-all.sh",
    ]

    when = "destroy"
  }

  connection {
    type        = "ssh"
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  # Used to destroy the jumpbox
  depends_on = [
    "google_compute_instance.jumpbox",
    "google_compute_disk.jumpbox_data",
    "google_compute_firewall.allow-ssh",
    "google_compute_firewall.internal-all",
    "google_compute_subnetwork.bosh",
    "google_compute_subnetwork.concourse",
    "google_compute_instance.nat-gateway-pri",
    "google_compute_route.nat-primary",
  ]
}
