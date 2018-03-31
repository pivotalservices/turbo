#### BOSH deployment
resource "null_resource" "bosh_deployments" {
  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.turbo_home}/deployments",
      "mkdir -p ${local.turbo_home}/deployments",
    ]
  }

  provisioner "file" {
    source      = "../../deployments/"
    destination = "${local.turbo_home}/deployments/"
  }

  provisioner "remote-exec" {
    inline = [
      "find ${local.turbo_home}/bosh/scripts/ -name \\*.sh -exec chmod +x {} \\;",
      "export TF_DEBUG=\"${var.debug}\"",
      "export TURBO_HOME=\"${local.turbo_home}\"",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "for dep in ${join(" ", local.deployments_list)}; do ${local.turbo_home}/bosh/scripts/generic/bosh-deploy.sh $dep || exit 1; done",
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
