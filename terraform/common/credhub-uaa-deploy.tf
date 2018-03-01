#### BOSH deployment
resource "null_resource" "credhub-uaa_scripts" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/credhub-uaa/ops",
      "mkdir -p /home/${var.ssh_user}/automation/scripts/credhub-uaa/generic",
    ]
  }

  provisioner "file" {
    source      = "../../scripts/credhub-uaa/generic/"
    destination = "/home/${var.ssh_user}/automation/scripts/credhub-uaa/generic/"
  }

  provisioner "file" {
    source      = "../../deployments/credhub-uaa/"
    destination = "/home/${var.ssh_user}/automation/credhub-uaa"
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

resource "null_resource" "credhub-uaa-deploy" {
  provisioner "remote-exec" {
    inline = [
      "find /home/${var.ssh_user}/automation/scripts/ -name \\*.sh -exec chmod +x {} \\;",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/scripts/credhub-uaa/generic/credhub-uaa-deploy.sh",
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
    dependencies_1 = "${null_resource.credhub-uaa_scripts.id}"
  }

  depends_on = [
    "null_resource.credhub-uaa-deploy-iaas-depedencies",
    "null_resource.credhub-uaa_scripts",
  ]
}
