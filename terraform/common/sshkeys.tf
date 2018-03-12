resource "tls_private_key" "jumpbox_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

output "jumpbox_ssh_private_key" {
  sensitive = true
  value     = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
}

output "jumpbox_ssh_public_key" {
  value = "${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
}

output "jumpbox_ssh_user" {
  value = "${var.ssh_user}"
}
