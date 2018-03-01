data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180228.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "jumpbox" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.jumpbox.id}"

  vpc_security_group_ids = [
    "${aws_security_group.jumpbox.id}",
  ]

  key_name = "${aws_key_pair.terraform.key_name}"

  tags {
    Name = "${var.env_name}-jumpbox"
  }
}

resource "aws_eip" "jumpbox" {
  instance = "${aws_instance.jumpbox.id}"
  vpc      = true

  depends_on = [
    "aws_internet_gateway.internet_gw",
  ]
}

resource "null_resource" "destroy-all" {
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-delete-all.sh",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "/home/${var.ssh_user}/automation/scripts/bosh/generic/bosh-delete-all.sh",
    ]

    when = "destroy"
  }

  connection {
    type        = "ssh"
    host        = "${aws_instance.jumpbox.public_ip}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  depends_on = [
    "aws_route_table_association.a_az1",
    "aws_security_group.jumpbox",
    "aws_security_group.bosh_deployed_vms",
    "aws_nat_gateway.global_nat_gw",
    "aws_internet_gateway.internet_gw",
    "aws_subnet.bosh",
    "aws_subnet.concourse",
    "aws_route_table_association.bosh_public_route",
    "aws_instance.jumpbox",
    "aws_eip.jumpbox",
    "aws_security_group_rule.all-out-bosh-vms",
    "aws_security_group_rule.all-in-bosh-vms",
    "aws_security_group_rule.jumpbox_ssh_in",
    "aws_security_group_rule.all-out",
  ]
}
