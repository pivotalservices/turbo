resource "aws_security_group" "jumpbox" {
  name        = "${var.env_name}-inbound-ssh-jumpbox"
  description = "${var.env_name} Inbound jumpbox ssh"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name = "${var.env_name}-jumpbox"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.source_admin_networks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bosh_deployed_vms" {
  name        = "${var.env_name}-bosh-deployed-vms"
  description = "${var.env_name} Default for bosh deployed vms"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name = "${var.env_name}-bosh-deployed-vms"
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.bootstrap_subnet}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
