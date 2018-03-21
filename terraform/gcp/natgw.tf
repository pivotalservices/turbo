resource "google_compute_instance" "nat-gateway-pri" {
  name           = "${var.env_name}-nat-gateway-pri-az${count.index + 1}"
  machine_type   = "${var.natgw_server_type}"
  zone           = "${element(var.gcp_zones,count.index)}"
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

  labels {
    turbo = "${var.env_name}"
  }

  metadata_startup_script = <<EOF
#!/usr/bin/env bash
sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
iptables -P FORWARD ACCEPT
ETH=$(ip link show | grep "UP," | grep -v lo: | cut -d ":" -f 2 | sed -e 's/\ //g')
iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
EOF

  count = "${length(var.gcp_zones)}"
}

resource "google_compute_route" "nat-primary" {
  name                   = "${var.env_name}-nat-pri-az${count.index + 1}"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.bootstrap.name}"
  next_hop_instance      = "${element(google_compute_instance.nat-gateway-pri.*.name,count.index)}"
  next_hop_instance_zone = "${element(var.gcp_zones,count.index)}"
  priority               = 800
  tags                   = ["${var.env_name}-nat"]
  project                = "${var.gcp_project_name}"
  count                  = "${length(var.gcp_zones)}"
}
