resource "tls_private_key" "jumpbox_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "jumpbox_ssh_private_key_file" {
  content  = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  filename = "./local/${terraform.workspace}/ssh/jumpbox"
}

resource "local_file" "jumpbox_ssh_public_key_file" {
  content  = "${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
  filename = "./local/${terraform.workspace}/ssh/jumpbox.pub"
}

output "jumpbox_ssh_private_key" {
  sensitive = true
  value     = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
}

output "jumpbox_ssh_user" {
  value = "${var.ssh_user}"
}
