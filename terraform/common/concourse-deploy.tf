#### BOSH deployment
resource "null_resource" "concourse_scripts" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/concourse/ops",
      "mkdir -p /home/${var.ssh_user}/automation/scripts/concourse/generic",
    ]
  }

  provisioner "file" {
    source      = "../../scripts/concourse/generic/"
    destination = "/home/${var.ssh_user}/automation/scripts/concourse/generic/"
  }

  provisioner "file" {
    source      = "../../deployments/concourse/"
    destination = "/home/${var.ssh_user}/automation/concourse"
  }

  connection {
    type        = "ssh"
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${local.jumpbox_id}"
    dependencies_1 = "${null_resource.cloud-config-update.id}"
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
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/scripts/concourse/generic/concourse-deploy.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${local.jumpbox_id}"
    dependencies_1 = "${null_resource.concourse_scripts.id}"
  }

  depends_on = [
    "null_resource.credhub-uaa-deploy",
    "null_resource.concourse_scripts",
    "null_resource.concourse-deploy-iaas-dependencies",
  ]
}
