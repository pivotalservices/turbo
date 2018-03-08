resource "aws_eip" "bosh_natgw" {
  vpc = true

  count = "${length(var.aws_azs)}"
}

resource "aws_nat_gateway" "global_nat_gw" {
  allocation_id = "${element(aws_eip.bosh_natgw.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.jumpbox.*.id, count.index)}"

  count = "${length(var.aws_azs)}"
}
