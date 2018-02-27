resource "template_dir" "bosh_generic_scripts" {
  source_dir      = "../../scripts/bosh/generic/"
  destination_dir = "${path.cwd}/local/automation/scripts/bosh/generic"

  vars {
    tf_ssh_user    = "${var.ssh_user}"
    tf_env_name    = "${var.env_name}"
    tf_cpi         = "${var.iaas_type}"
    tf_internal_ip = "${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range, 6)}"
  }
}

resource "template_dir" "bosh_iaas_specific_scripts" {
  source_dir      = "../../scripts/bosh/iaas-specific/${var.iaas_type}/"
  destination_dir = "${path.cwd}/local/automation/scripts/bosh/iaas-specific/${var.iaas_type}"

  vars {
    tf_ssh_user      = "${var.ssh_user}"
    tf_env_name      = "${var.env_name}"
    tf_internal_cidr = "${google_compute_subnetwork.bosh.ip_cidr_range}"
    tf_internal_gw   = "${google_compute_subnetwork.bosh.gateway_address}"
    tf_internal_ip   = "${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range, 6)}"
    tf_project_id    = "${var.gcp_project_name}"
    tf_zone          = "${var.gcp_zone_1}"
    tf_network       = "${google_compute_network.bootstrap.name}"
    tf_subnetwork    = "${google_compute_subnetwork.bosh.name}"
    tf_cpi           = "${var.iaas_type}"
  }
}

resource "null_resource" "bosh_all_scripts" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/scripts/bosh/generic",
      "mkdir -p /home/${var.ssh_user}/automation/scripts/bosh/iaas-specific",
    ]
  }

  provisioner "file" {
    source      = "${template_dir.bosh_generic_scripts.destination_dir}"
    destination = "/home/${var.ssh_user}/automation/scripts/bosh/"
  }

  provisioner "file" {
    source      = "${template_dir.bosh_iaas_specific_scripts.destination_dir}/"
    destination = "/home/${var.ssh_user}/automation/scripts/bosh/iaas-specific/"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    dependencies_1 = "${template_dir.bosh_generic_scripts.id}"
    dependencies_1 = "${template_dir.bosh_iaas_specific_scripts.id}"
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    always         = "${uuid()}"
  }

  depends_on = [
    "google_compute_instance.jumpbox",
  ]
}

resource "null_resource" "bosh_dependencies_exec" {
  provisioner "remote-exec" {
    inline = [
      "find /home/${var.ssh_user}/automation/scripts/ -name \\*.sh -exec chmod +x {} \\;",
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-dependencies.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    dependencies = "${null_resource.bosh_all_scripts.id}"
    jumpbox_id   = "${google_compute_instance.jumpbox.id}"
  }

  depends_on = [
    "null_resource.bosh_all_scripts",
  ]
}

resource "null_resource" "bosh-create-env" {
  provisioner "file" {
    content     = "${var.gcp_key}"
    destination = "/home/${var.ssh_user}/automation/gcp_key.json"
  }

  provisioner "remote-exec" {
    inline = [
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-create-env.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    dependencies_1 = "${null_resource.bosh_dependencies_exec.id}"
    dependencies_3 = "${md5(var.gcp_key)}"
  }

  depends_on = [
    "null_resource.bosh_dependencies_exec",
  ]
}
