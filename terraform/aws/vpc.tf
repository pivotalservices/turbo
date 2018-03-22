resource "aws_vpc" "bootstrap" {
  cidr_block = "${var.bootstrap_subnet}"

  tags {
    Name  = "${var.env_name}-boostrap"
    turbo = "${var.env_name}"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-internet-gateway"
    turbo = "${var.env_name}"
  }
}

# 3. NAT instance setup
# 3.1 Security Group for NAT
resource "aws_security_group" "nat_instance_sg" {
  name        = "${var.env_name}-nat_instance_sg"
  description = "${var.env_name} NAT Instance Security Group"
  vpc_id      = "${aws_vpc.bootstrap.id}"

  tags {
    Name  = "${var.env_name}-NAT intance security group"
    turbo = "${var.env_name}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${aws_vpc.bootstrap.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3.2 Create NAT instance
# resource "aws_instance" "nat_az1" {
#   ami                         = "${var.amis_nat}"
#   availability_zone           = "${var.aws_az1}"
#   instance_type               = "${var.nat_instance_type}"
#   key_name                    = "${var.aws_key_name}"
#   vpc_security_group_ids      = ["${aws_security_group.nat_instance_sg.id}"]
#   subnet_id                   = "${aws_subnet.PcfVpcPublicSubnet_az1.id}"
#   associate_public_ip_address = true
#   source_dest_check           = false
#   private_ip                  = "${var.nat_ip_az1}"


#   tags {
#     Name = "${var.prefix}-Nat Instance az1"
#   }
# }

