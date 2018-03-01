resource "null_resource" "cloud-config-upload" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/bosh/cloud-config",
    ]
  }

  provisioner "file" {
    source      = "../../cloud-config/${local.iaas_type}/cloud-config.yml"
    destination = "/home/${var.ssh_user}/automation/bosh/cloud-config/cloud-config.yml"
  }

  connection {
    type        = "ssh"
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id = "${local.jumpbox_id}"
    always     = "${uuid()}"
  }

  depends_on = [
    "null_resource.bosh-create-env",
  ]
}

resource "null_resource" "cloud-config-update" {
  provisioner "remote-exec" {
    inline = [
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-cloud-config.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id = "${local.jumpbox_id}"

    # dependencies_1 = "${md5(data.template_file.cloud-config.rendered)}"
    dependencies_2 = "${null_resource.cloud-config-upload.id}"
  }

  depends_on = [
    "null_resource.cloud-config-upload",
    "null_resource.bosh-create-env",
  ]
}
