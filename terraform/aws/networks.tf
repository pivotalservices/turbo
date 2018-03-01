resource "aws_subnet" "jumpbox" {
  vpc_id            = "${aws_vpc.bootstrap.id}"
  cidr_block        = "${cidrsubnet(var.bootstrap_subnet, 2, 0)}"
  availability_zone = "${var.aws_az_1}"

  tags {
    Name = "${var.env_name}-jumpbox"
  }
}

resource "aws_subnet" "bosh" {
  vpc_id            = "${aws_vpc.bootstrap.id}"
  cidr_block        = "${cidrsubnet(var.bootstrap_subnet, 2, 1)}"
  availability_zone = "${var.aws_az_1}"

  tags {
    Name = "${var.env_name}-bosh"
  }
}

resource "aws_subnet" "concourse" {
  vpc_id            = "${aws_vpc.bootstrap.id}"
  cidr_block        = "${cidrsubnet(var.bootstrap_subnet, 2, 2)}"
  availability_zone = "${var.aws_az_1}"

  tags {
    Name = "${var.env_name}-concourse"
  }
}
