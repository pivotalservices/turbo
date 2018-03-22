resource "aws_subnet" "jumpbox" {
  vpc_id            = "${aws_vpc.bootstrap.id}"
  cidr_block        = "${cidrsubnet(cidrsubnet(var.bootstrap_subnet, 2, count.index), 2, 0)}"
  availability_zone = "${element(var.aws_azs, count.index)}"

  tags {
    Name  = "${var.env_name}-jumpbox-az${count.index}"
    turbo = "${var.env_name}"
  }

  count = "${length(var.aws_azs)}"
}

resource "aws_subnet" "bosh" {
  vpc_id            = "${aws_vpc.bootstrap.id}"
  cidr_block        = "${cidrsubnet(cidrsubnet(var.bootstrap_subnet, 2, count.index), 2, 1)}"
  availability_zone = "${element(var.aws_azs, count.index)}"

  tags {
    Name  = "${var.env_name}-bosh-az${count.index}"
    turbo = "${var.env_name}"
  }

  count = "${length(var.aws_azs)}"
}

resource "aws_subnet" "concourse" {
  vpc_id            = "${aws_vpc.bootstrap.id}"
  cidr_block        = "${cidrsubnet(cidrsubnet(var.bootstrap_subnet, 2, count.index), 2, 2)}"
  availability_zone = "${element(var.aws_azs, count.index)}"

  tags {
    Name  = "${var.env_name}-concourse-az${count.index}"
    turbo = "${var.env_name}"
  }

  count = "${length(var.aws_azs)}"
}
