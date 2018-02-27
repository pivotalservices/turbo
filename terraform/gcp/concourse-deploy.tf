#### BOSH deployment
resource "template_dir" "concourse_generic_scripts" {
  source_dir      = "../../scripts/concourse/generic/"
  destination_dir = "${path.cwd}/local/automation/scripts/concourse/generic"

  vars {
    tf_ssh_user               = "${var.ssh_user}"
    tf_env_name               = "${var.env_name}"
    tf_concourse_subnet_range = "${google_compute_subnetwork.concourse.ip_cidr_range}"
    tf_concourse_dns_entry    = "${replace(google_dns_record_set.concourse-lb.name,"/\\.$/","")}"
    tf_flags                  = "${replace(jsonencode(var.flags), "\"", "\\\"")}"
    tf_lb_ca                  = "${tls_self_signed_cert.rootca_cert.cert_pem}"
    tf_domain_name            = "${var.dns_domain_name}"
  }
}

resource "null_resource" "concourse_scripts" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/concourse/ops",
      "mkdir -p /home/${var.ssh_user}/automation/scripts/concourse/generic",
    ]
  }

  provisioner "file" {
    source      = "${template_dir.concourse_generic_scripts.destination_dir}"
    destination = "/home/${var.ssh_user}/automation/scripts/concourse"
  }

  provisioner "file" {
    source      = "../../deployments/concourse/"
    destination = "/home/${var.ssh_user}/automation/concourse"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    dependencies_1 = "${null_resource.cloud-config-update.id}"
    dependencies_2 = "${template_dir.concourse_generic_scripts.id}"
    always         = "${uuid()}"
  }

  depends_on = [
    "null_resource.cloud-config-update",
  ]
}

resource "null_resource" "concourse-deploy" {
  provisioner "remote-exec" {
    inline = [
      "find /home/${var.ssh_user}/automation/scripts/ -name \\*.sh -exec chmod +x {} \\;",
      "/home/${var.ssh_user}/automation/scripts/concourse/generic/concourse-deploy.sh",
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
    dependencies_1 = "${null_resource.concourse_scripts.id}"
  }

  depends_on = [
    "null_resource.credhub-uaa-deploy",
    "null_resource.concourse_scripts",
    "google_compute_backend_service.concourse_web_lb_https_backend_service",
  ]
}
