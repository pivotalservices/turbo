resource "tls_private_key" "jumpbox_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "jumpbox_ssh_private_key_file" {
  content  = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  filename = "./local/ssh/jumpbox"
}

resource "local_file" "jumpbox_ssh_public_key_file" {
  content  = "${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
  filename = "./local/ssh/jumpbox.pub"
}

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
