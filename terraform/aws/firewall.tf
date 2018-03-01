resource "aws_security_group" "jumpbox" {
  name        = "${var.env_name}-inbound-ssh-jumpbox"
  description = "${var.env_name} Inbound jumpbox ssh"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name = "${var.env_name}-Inbound jumpbox ssh"
  }
}

resource "aws_security_group_rule" "jumpbox_ssh_in" {
  security_group_id = "${aws_security_group.jumpbox.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.source_admin_networks}"]
}

resource "aws_security_group_rule" "all-out" {
  security_group_id = "${aws_security_group.jumpbox.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "bosh_deployed_vms" {
  name        = "${var.env_name}-bosh-deployed-vms"
  description = "${var.env_name} Default for bosh deployed vms"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name = "${var.env_name}-Default for bosh deployed vms"
  }
}

resource "aws_security_group_rule" "all-out-bosh-vms" {
  security_group_id = "${aws_security_group.bosh_deployed_vms.id}"
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all-in-bosh-vms" {
  security_group_id = "${aws_security_group.bosh_deployed_vms.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
