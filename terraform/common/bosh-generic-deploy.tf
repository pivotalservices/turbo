#### BOSH deployment
resource "null_resource" "bosh_deployments" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/deployments",
    ]
  }

  provisioner "file" {
    source      = "../../deployments/"
    destination = "/home/${var.ssh_user}/automation/deployments/"
  }

  provisioner "remote-exec" {
    inline = [
      "find /home/${var.ssh_user}/automation/bosh/scripts/ -name \\*.sh -exec chmod +x {} \\;",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "for dep in ${join(" ", local.deployments_list)}; do /home/${var.ssh_user}/automation/bosh/scripts/generic/bosh-deploy.sh $dep || exit 1; done",
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
    dependencies_1 = "${null_resource.cloud-config-update.id}"
    always         = "${uuid()}"
  }

  depends_on = [
    "null_resource.cloud-config-update",
    "null_resource.bosh_deploy_dependencies",
  ]
}
