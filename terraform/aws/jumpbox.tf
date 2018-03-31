data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_ebs_volume" "jumpbox_data" {
  availability_zone = "${var.aws_azs[0]}"
  size              = 10
  encrypted         = true
  type              = "gp2"

  tags {
    Name  = "${var.env_name}-jumpbox-data"
    turbo = "${var.env_name}"
  }
}

resource "aws_volume_attachment" "jumpbox_data_att" {
  device_name = "/dev/xvdh"
  volume_id   = "${aws_ebs_volume.jumpbox_data.id}"
  instance_id = "${aws_instance.jumpbox.id}"

  skip_destroy = true
}

resource "aws_instance" "jumpbox" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "t2.micro"
  subnet_id         = "${aws_subnet.jumpbox.0.id}"
  availability_zone = "${var.aws_azs[0]}"

  vpc_security_group_ids = [
    "${aws_security_group.jumpbox.id}",
  ]

  key_name = "${aws_key_pair.terraform.key_name}"

  tags {
    Name  = "${var.env_name}-jumpbox"
    turbo = "${var.env_name}"
  }

  user_data = <<EOF
#!/usr/bin/env bash
while [ ! -d /sys/block/xvdh ]; do sleep 1; done
if [ ! -d /sys/block/xvdh/xvdh1 ]; then
    echo -e "g\nn\np\n1\n\n\nw" | sudo fdisk /dev/xvdh
    sudo mkfs.ext4 /dev/xvdh1
fi
sudo mkdir /data
sudo mount /dev/xvdh1 /data
if ! grep $(hostname) /etc/hosts; then
  echo "127.0.1.1" $(hostname) >> /etc/hosts
fi
EOF
}

resource "aws_eip" "jumpbox" {
  instance = "${aws_instance.jumpbox.id}"
  vpc      = true

  depends_on = [
    "aws_internet_gateway.internet_gw",
  ]

  tags {
    Name  = "${var.env_name}-jumpbox-eip"
    turbo = "${var.env_name}"
  }
}

resource "null_resource" "destroy-all" {
  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.turbo_home}/bosh/",
      "mkdir -p ${local.turbo_home}/bosh/",
    ]

    when = "destroy"
  }

  provisioner "file" {
    source      = "../../bosh/"
    destination = "${local.turbo_home}/bosh/"

    when = "destroy"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.turbo_home}/bosh/scripts/generic/bosh-delete-all.sh",
      "export TF_DEBUG=\"${var.debug}\"",
      "export TURBO_HOME=\"${local.turbo_home}\"",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "${local.turbo_home}/bosh/scripts/generic/bosh-delete-all.sh",
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
    "aws_route_table_association.jumpbox_public_route",
    "aws_security_group.jumpbox",
    "aws_security_group.bosh_deployed_vms",
    "aws_nat_gateway.global_nat_gw",
    "aws_internet_gateway.internet_gw",
    "aws_subnet.bosh",
    "aws_subnet.concourse",
    "aws_route_table_association.bosh_public_route",
    "aws_instance.jumpbox",
    "aws_eip.jumpbox",
    "aws_volume_attachment.jumpbox_data_att",
    "aws_ebs_volume.jumpbox_data",
  ]
}
