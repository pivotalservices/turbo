resource "null_resource" "init-jumpbox" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id = "${google_compute_instance.jumpbox.id}"
  }

  depends_on = [
    "google_compute_instance.jumpbox",
  ]
}

data "template_file" "bosh-dependencies" {
  template = "${file("../../scripts/bosh-dependencies.sh")}"
}

resource "null_resource" "bosh-dependencies" {
  provisioner "file" {
    content     = "${data.template_file.bosh-dependencies.rendered}"
    destination = "/home/${var.ssh_user}/automation/bosh-dependencies.sh"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    dependencies = "${md5(data.template_file.bosh-dependencies.rendered)}"
    jumpbox_id   = "${google_compute_instance.jumpbox.id}"
  }

  depends_on = [
    "null_resource.init-jumpbox",
  ]
}

resource "null_resource" "bosh-dependencies-exec" {
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/automation/bosh-dependencies.sh",
      "/home/${var.ssh_user}/automation/bosh-dependencies.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    dependencies = "${md5(data.template_file.bosh-dependencies.rendered)}"
    jumpbox_id   = "${google_compute_instance.jumpbox.id}"
  }

  depends_on = [
    "null_resource.bosh-dependencies",
  ]
}

data "template_file" "bosh-create-env" {
  template = "${file("../../scripts/bosh-create-env.tpl.sh")}"

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

data "template_file" "bosh-delete-env" {
  template = "${file("../../scripts/bosh-delete-all.tpl.sh")}"

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

resource "null_resource" "bosh-create-env" {
  provisioner "file" {
    content     = "${data.template_file.bosh-delete-env.rendered}"
    destination = "/home/${var.ssh_user}/automation/bosh-delete-all.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.bosh-create-env.rendered}"
    destination = "/home/${var.ssh_user}/automation/bosh-create-env.sh"
  }

  provisioner "file" {
    content     = "${var.gcp_key}"
    destination = "/home/${var.ssh_user}/automation/gcp_key.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/automation/bosh-create-env.sh",
      "chmod +x /home/${var.ssh_user}/automation/bosh-delete-all.sh",
      "/home/${var.ssh_user}/automation/bosh-create-env.sh",
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
    dependencies_1 = "${md5(data.template_file.bosh-create-env.rendered)}"
    dependencies_2 = "${md5(data.template_file.bosh-delete-env.rendered)}"
    dependencies_3 = "${md5(var.gcp_key)}"
  }

  depends_on = [
    "null_resource.bosh-dependencies-exec",
  ]
}
