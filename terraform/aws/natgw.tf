resource "aws_eip" "bosh_natgw" {
  vpc = true

  count = "${length(var.aws_azs)}"

  tags {
    Name  = "${var.env_name}-natgw-az${count.index + 1}-eip"
    turbo = "${var.env_name}"
  }
}

resource "aws_nat_gateway" "global_nat_gw" {
  allocation_id = "${element(aws_eip.bosh_natgw.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.jumpbox.*.id, count.index)}"

  count = "${length(var.aws_azs)}"

  tags {
    Name  = "${var.env_name}-natgw-az${count.index + 1}"
    turbo = "${var.env_name}"
  }
}
