locals {
  ssh_host   = "${aws_eip.jumpbox.public_ip}"
  jumpbox_id = "${aws_instance.jumpbox.id}"
}

locals {
  stemcell  = "bosh-aws-xen-hvm-ubuntu-trusty-go_agent"
  iaas_type = "aws"

  iaas_flags = {}
}

locals {
  iaas_env = {
    TF_FLAGS = "${jsonencode(local.flags)}"

    AWS_SECRET_KEY   = "${var.aws_secret_key}"
    AWS_ACCESS_KEY   = "${var.aws_access_key}"
    SSH_PRIVATE_KEY  = "${tls_private_key.bosh_ssh_private_key.private_key_pem}"
    TF_STEMCELL_TYPE = "${local.stemcell}"

    # BOSH
    TF_SSH_USER      = "${var.ssh_user}"
    TF_CPI           = "${local.iaas_type}"
    TF_INTERNAL_IP   = "${cidrhost(aws_subnet.bosh.0.cidr_block, 6)}"
    TF_INTERNAL_CIDR = "${aws_subnet.bosh.0.cidr_block}"
    TF_INTERNAL_GW   = "${cidrhost(aws_subnet.bosh.0.cidr_block,1)}"
    TF_AWS_REGION    = "${var.aws_region}"
    TF_AWS_AZ_COUNT  = "${length(var.aws_azs)}"
    TF_AZ_LIST       = "${length(var.aws_azs) == 1 ? "[z1]" :
                          length(var.aws_azs) == 2 ? "[z1,z2]" : "[z1,z2,z3]"}"

    TF_AWS_AZ_1 = "${var.aws_azs[0]}"
    TF_AWS_AZ_2 = "${length(var.aws_azs) >= 2 ? element(var.aws_azs,1) : ""}"
    TF_AWS_AZ_3 = "${length(var.aws_azs) == 3 ? element(var.aws_azs,2) : ""}"

    TF_BOSH_SSH_KEY             = "${aws_key_pair.bosh.key_name}"
    TF_BOSH_VMS_SECURITY_GROUPS = "[${aws_security_group.bosh_deployed_vms.name}]"
    TF_BOSH_SUBNET_ID           = "${aws_subnet.bosh.0.id}"

    # Cloud Config
    TF_AZ1_CONCOURSE_SUBNET_RANGE         = "${aws_subnet.concourse.0.cidr_block}"
    TF_AZ1_CONCOURSE_SUBNET_GATEWAY       = "${cidrhost(aws_subnet.concourse.0.cidr_block,1)}"
    TF_AZ1_CONCOURSE_NETWORK_STATIC_IPS   = "[${cidrhost(aws_subnet.concourse.0.cidr_block,5)}-${cidrhost(aws_subnet.concourse.0.cidr_block,8)}]"
    TF_AZ1_CONCOURSE_NETWORK_RESERVED_IPS = "[${cidrhost(aws_subnet.concourse.0.cidr_block,0)}-${cidrhost(aws_subnet.concourse.0.cidr_block,4)}]"
    TF_AZ1_CONCOURSE_SUBNET_ID            = "${aws_subnet.concourse.0.id}"

    TF_AZ2_CONCOURSE_SUBNET_RANGE         = "${length(var.aws_azs) >= 2 ? element(aws_subnet.concourse.*.cidr_block,1) : ""}"
    TF_AZ2_CONCOURSE_SUBNET_GATEWAY       = "${length(var.aws_azs) >= 2 ? cidrhost(element(aws_subnet.concourse.*.cidr_block,1),1) : ""}"
    TF_AZ2_CONCOURSE_NETWORK_STATIC_IPS   = "${length(var.aws_azs) >= 2 ? format("[%s-%s]", cidrhost(element(aws_subnet.concourse.*.cidr_block,1),5), cidrhost(element(aws_subnet.concourse.*.cidr_block,1),8)) : ""}"
    TF_AZ2_CONCOURSE_NETWORK_RESERVED_IPS = "${length(var.aws_azs) >= 2 ? format("[%s-%s]", cidrhost(element(aws_subnet.concourse.*.cidr_block,1),0), cidrhost(element(aws_subnet.concourse.*.cidr_block,1),4)) : ""}"
    TF_AZ2_CONCOURSE_SUBNET_ID            = "${length(var.aws_azs) >= 2 ? element(aws_subnet.concourse.*.id,1) : ""}"

    TF_AZ3_CONCOURSE_SUBNET_RANGE         = "${length(var.aws_azs) >= 3 ? element(aws_subnet.concourse.*.cidr_block,2) : ""}"
    TF_AZ3_CONCOURSE_SUBNET_GATEWAY       = "${length(var.aws_azs) >= 3 ? cidrhost(element(aws_subnet.concourse.*.cidr_block,2),1) : ""}"
    TF_AZ3_CONCOURSE_NETWORK_STATIC_IPS   = "${length(var.aws_azs) >= 3 ? format("[%s-%s]", cidrhost(element(aws_subnet.concourse.*.cidr_block,2),5), cidrhost(element(aws_subnet.concourse.*.cidr_block,2),8)) : ""}"
    TF_AZ3_CONCOURSE_NETWORK_RESERVED_IPS = "${length(var.aws_azs) >= 3 ? format("[%s-%s]", cidrhost(element(aws_subnet.concourse.*.cidr_block,2),0), cidrhost(element(aws_subnet.concourse.*.cidr_block,2),4)) : ""}"
    TF_AZ3_CONCOURSE_SUBNET_ID            = "${length(var.aws_azs) >= 3 ? element(aws_subnet.concourse.*.id,2) : ""}"

    TF_CONCOURSE_WEB_BACKEND_GROUP = "${aws_elb.concourse-elb.name}"
    TF_CREDHUB_BACKEND_GROUP       = "${aws_elb.credhub-elb.name}"
    TF_UAA_BACKEND_GROUP           = "${aws_elb.uaa-elb.name}"

    TF_BOSH_SUBNET_RANGE         = "${aws_subnet.bosh.0.cidr_block}"
    TF_BOSH_SUBNET_GATEWAY       = "${cidrhost(aws_subnet.bosh.0.cidr_block,1)}"
    TF_BOSH_NETWORK_STATIC_IPS   = "[${cidrhost(aws_subnet.bosh.0.cidr_block,7)}-${cidrhost(aws_subnet.bosh.0.cidr_block,10)}]"
    TF_BOSH_NETWORK_RESERVED_IPS = "[${cidrhost(aws_subnet.bosh.0.cidr_block,0)}-${cidrhost(aws_subnet.bosh.0.cidr_block,6)}]"
    TF_BOSH_SUBNET_ID            = "${aws_subnet.bosh.0.id}"

    TF_METRICS_BACKEND_GROUP = "${local.common_flags["metrics"] == "true" ? join(" ", aws_elb.metrics-elb.*.name) : "DUMMY"}"

    # Credhub UAA
    TF_CREDHUB_DNS_ENTRY = "${aws_route53_record.credhub.name}.${var.dns_domain_name}"
    TF_UAA_DNS_ENTRY     = "${aws_route53_record.uaa.name}.${var.dns_domain_name}"

    # Concourse
    TF_CONCOURSE_EXTERNAL_URL = "https://${aws_route53_record.concourse.name}.${var.dns_domain_name}"
    TF_DOMAIN_NAME            = "${var.dns_domain_name}"
    TF_CREDHUB_URL            = "https://${aws_route53_record.credhub.name}.${var.dns_domain_name}"

    # Other
    TF_DB_STATIC_IP      = "${cidrhost(aws_subnet.concourse.0.cidr_block,6)}"
    TF_METRICS_STATIC_IP = "${cidrhost(aws_subnet.concourse.0.cidr_block,7)}"

    # IAAS
    TF_LB_CA      = ""
    TF_LB_PUB_KEY = ""
  }
}
