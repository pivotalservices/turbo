resource "null_resource" "bosh_all_scripts" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/scripts/bosh/generic",
      "mkdir -p /home/${var.ssh_user}/automation/scripts/bosh/iaas-specific",
    ]
  }

  provisioner "file" {
    source      = "../../scripts/bosh/generic/"
    destination = "/home/${var.ssh_user}/automation/scripts/bosh/generic/"
  }

  provisioner "file" {
    source      = "../../scripts/bosh/iaas-specific/${local.iaas_type}/"
    destination = "/home/${var.ssh_user}/automation/scripts/bosh/iaas-specific/"
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
    "null_resource.bosh_iaas_specific_dependencies",
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
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    dependencies = "${null_resource.bosh_all_scripts.id}"
    jumpbox_id   = "${local.jumpbox_id}"
  }

  depends_on = [
    "null_resource.bosh_all_scripts",
  ]
}

resource "null_resource" "bosh-create-env" {
  provisioner "remote-exec" {
    inline = [
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-create-env.sh",
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
    dependencies_1 = "${null_resource.bosh_dependencies_exec.id}"
  }

  depends_on = [
    "null_resource.bosh_dependencies_exec",
  ]
}
