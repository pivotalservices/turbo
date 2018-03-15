resource "null_resource" "bosh-create-env" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/bosh/",
    ]
  }

  provisioner "file" {
    source      = "../../bosh/"
    destination = "/home/${var.ssh_user}/automation/bosh/"
  }

  provisioner "remote-exec" {
    inline = [
      "find /home/${var.ssh_user}/automation/bosh/scripts -name \\*.sh -exec chmod +x {} \\;",
      "/home/${var.ssh_user}/automation/bosh/scripts/generic/bosh-dependencies.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/bosh/scripts/generic/bosh-create-env.sh",
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
