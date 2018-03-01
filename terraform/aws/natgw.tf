resource "aws_eip" "bosh_natgw" {
  vpc = true
}

resource "aws_nat_gateway" "global_nat_gw" {
  allocation_id = "${aws_eip.bosh_natgw.id}"
  subnet_id     = "${aws_subnet.jumpbox.id}"
}
