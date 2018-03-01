resource "aws_route_table" "PublicSubnetRouteTable" {
  vpc_id = "${aws_vpc.bootstrap.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }

  tags {
    Name = "${var.env_name}-Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "a_az1" {
  subnet_id      = "${aws_subnet.jumpbox.id}"
  route_table_id = "${aws_route_table.PublicSubnetRouteTable.id}"
}

resource "aws_route_table" "no_ip" {
  vpc_id = "${aws_vpc.bootstrap.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.global_nat_gw.id}"
  }

  tags {
    Name = "${var.env_name}-no-ip-route-table"
  }
}

resource "aws_route_table_association" "bosh_public_route" {
  subnet_id      = "${aws_subnet.bosh.id}"
  route_table_id = "${aws_route_table.no_ip.id}"
}

resource "aws_route_table_association" "concourse_public_route" {
  subnet_id      = "${aws_subnet.concourse.id}"
  route_table_id = "${aws_route_table.no_ip.id}"
}
