resource "google_compute_instance" "nat-gateway-pri" {
  name           = "${var.env_name}-nat-gateway-pri"
  machine_type   = "${var.natgw_server_type}"
  zone           = "${var.gcp_zone_1}"
  can_ip_forward = true
  tags           = ["${var.env_name}-nat-instance", "${var.env_name}-internal"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.jumpbox.name}"

    access_config {
      // Ephemeral
    }
  }

  metadata_startup_script = <<EOF
#!/usr/bin/env bash
sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
iptables -P FORWARD ACCEPT
ETH=$(ip link show | grep "UP," | grep -v lo: | cut -d ":" -f 2 | sed -e 's/\ //g')
iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
EOF
}

resource "google_compute_route" "nat-primary" {
  name                   = "${var.env_name}-nat-pri"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.bootstrap.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-pri.name}"
  next_hop_instance_zone = "${var.gcp_zone_1}"
  priority               = 800
  tags                   = ["${var.env_name}-nat"]
  project                = "${var.gcp_project_name}"
}
