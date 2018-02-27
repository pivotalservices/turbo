data "template_file" "cloud-config" {
  template = "${file("../../cloud-config/gcp/bosh-cloud-config.tpl.yml")}"

  vars {
    tf_env_name                    = "${var.env_name}"
    tf_concourse_subnet_range      = "${google_compute_subnetwork.concourse.ip_cidr_range}"
    tf_concourse_subnet_gateway    = "${google_compute_subnetwork.concourse.gateway_address}"
    tf_concourse_subnet_name       = "${google_compute_subnetwork.concourse.name}"
    tf_bootstrap_network_name      = "${google_compute_network.bootstrap.name}"
    tf_gcp_zone_1                  = "${var.gcp_zone_1}"
    tf_concourse_web_backend_group = "${google_compute_backend_service.concourse_web_lb_https_backend_service.name}"
    tf_credhub_backend_group       = "${google_compute_backend_service.credhub_lb_https_backend_service.name}"
    tf_uaa_backend_group           = "${google_compute_backend_service.uaa_lb_https_backend_service.name}"
  }
}

resource "null_resource" "cloud-config-upload" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/bosh/cloud-config",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.cloud-config.rendered}"
    destination = "/home/${var.ssh_user}/automation/bosh/cloud-config/cloud-config.yml"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    dependencies_1 = "${md5(data.template_file.cloud-config.rendered)}"
    always         = "${uuid()}"
  }

  depends_on = [
    "null_resource.bosh-create-env",
  ]
}

resource "null_resource" "cloud-config-update" {
  provisioner "remote-exec" {
    inline = [
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-cloud-config.sh",
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
    dependencies_1 = "${md5(data.template_file.cloud-config.rendered)}"
    dependencies_2 = "${null_resource.cloud-config-upload.id}"
  }

  depends_on = [
    "null_resource.cloud-config-upload",
    "null_resource.bosh-create-env",
  ]
}
