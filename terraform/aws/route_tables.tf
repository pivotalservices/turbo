resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.bootstrap.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }

  tags {
    Name = "${var.env_name}-Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "jumpbox_public_route" {
  subnet_id      = "${element(aws_subnet.jumpbox.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"

  count = "${length(var.aws_azs)}"
}

resource "aws_route_table" "no_ip" {
  vpc_id = "${aws_vpc.bootstrap.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.global_nat_gw.*.id, count.index)}"
  }

  tags {
    Name = "${var.env_name}-no-ip-route-table"
  }

  count = "${length(var.aws_azs)}"
}

resource "aws_route_table_association" "bosh_public_route" {
  subnet_id      = "${element(aws_subnet.bosh.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.no_ip.*.id,count.index)}"

  count = "${length(var.aws_azs)}"
}

resource "aws_route_table_association" "concourse_public_route" {
  subnet_id      = "${element(aws_subnet.concourse.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.no_ip.*.id,count.index)}"

  count = "${length(var.aws_azs)}"
}
