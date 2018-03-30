resource "null_resource" "bosh-create-env" {
  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.turbo_home}/bosh/",
      "mkdir -p ${local.turbo_home}/bosh/",
    ]
  }

  provisioner "file" {
    source      = "../../bosh/"
    destination = "${local.turbo_home}/bosh/"
  }

  provisioner "remote-exec" {
    inline = [
      "find ${local.turbo_home}/bosh/scripts -name \\*.sh -exec chmod +x {} \\;",
      "${local.turbo_home}/bosh/scripts/generic/bosh-dependencies.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "export TF_DEBUG=\"${var.debug}\"",
      "export TURBO_HOME=\"${local.turbo_home}\"",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "${local.turbo_home}/bosh/scripts/generic/bosh-create-env.sh",
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
    always     = "${uuid()}"
  }

  depends_on = [
    "null_resource.bosh_iaas_specific_dependencies",
  ]
}
