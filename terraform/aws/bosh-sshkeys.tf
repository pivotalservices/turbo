resource "aws_key_pair" "terraform" {
  key_name   = "${var.env_name}-terraform"
  public_key = "${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
}

resource "tls_private_key" "bosh_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "bosh" {
  key_name   = "${var.env_name}-bosh"
  public_key = "${tls_private_key.bosh_ssh_private_key.public_key_openssh}"
}
