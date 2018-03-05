locals {
  ssh_host   = "${aws_eip.jumpbox.public_ip}"
  jumpbox_id = "${aws_instance.jumpbox.id}"
}

locals {
  stemcell  = "bosh-aws-xen-hvm-ubuntu-trusty-go_agent"
  iaas_type = "aws"

  flags = {
    use_external_postgres = "false"
    ha_concourse          = "false"
    aws_elb               = "true"
  }
}

locals {
  iaas_env = {
    TF_FLAGS = "${jsonencode(local.flags)}"

    AWS_SECRET_KEY   = "${var.aws_secret_key}"
    AWS_ACCESS_KEY   = "${var.aws_access_key}"
    SSH_PRIVATE_KEY  = "${tls_private_key.bosh_ssh_private_key.private_key_pem}"
    TF_STEMCELL_TYPE = "${local.stemcell}"

    # BOSH
    TF_DIRECTOR_NAME            = "${var.env_name}-bosh1"
    TF_SSH_USER                 = "${var.ssh_user}"
    TF_ENV_NAME                 = "${var.env_name}"
    TF_CPI                      = "${local.iaas_type}"
    TF_INTERNAL_IP              = "${cidrhost(aws_subnet.bosh.cidr_block, 6)}"
    TF_INTERNAL_CIDR            = "${aws_subnet.bosh.cidr_block}"
    TF_INTERNAL_GW              = "${cidrhost(aws_subnet.bosh.cidr_block,1)}"
    TF_AWS_REGION               = "${var.aws_region}"
    TF_AZ_1                     = "${var.aws_az_1}"
    TF_BOSH_SSH_KEY             = "${aws_key_pair.bosh.key_name}"
    TF_BOSH_VMS_SECURITY_GROUPS = "[${aws_security_group.bosh_deployed_vms.name}]"
    TF_BOSH_SUBNET_ID           = "${aws_subnet.bosh.id}"

    # Cloud Config
    TF_CONCOURSE_SUBNET_RANGE         = "${aws_subnet.concourse.cidr_block}"
    TF_CONCOURSE_SUBNET_GATEWAY       = "${cidrhost(aws_subnet.concourse.cidr_block,1)}"
    TF_CONCOURSE_NETWORK_STATIC_IPS   = "[${cidrhost(aws_subnet.concourse.cidr_block,5)}-${cidrhost(aws_subnet.concourse.cidr_block,8)}]"
    TF_CONCOURSE_NETWORK_RESERVED_IPS = "[${cidrhost(aws_subnet.concourse.cidr_block,0)}-${cidrhost(aws_subnet.concourse.cidr_block,4)}]"
    TF_CONCOURSE_SUBNET_ID            = "${aws_subnet.concourse.id}"
    TF_CONCOURSE_WEB_BACKEND_GROUP    = "${aws_elb.concourse-elb.name}"
    TF_CREDHUB_BACKEND_GROUP          = "${aws_elb.credhub-elb.name}"
    TF_UAA_BACKEND_GROUP              = "${aws_elb.uaa-elb.name}"

    TF_BOSH_SUBNET_RANGE         = "${aws_subnet.bosh.cidr_block}"
    TF_BOSH_SUBNET_GATEWAY       = "${cidrhost(aws_subnet.bosh.cidr_block,1)}"
    TF_BOSH_NETWORK_STATIC_IPS   = "[${cidrhost(aws_subnet.bosh.cidr_block,7)}-${cidrhost(aws_subnet.bosh.cidr_block,10)}]"
    TF_BOSH_NETWORK_RESERVED_IPS = "[${cidrhost(aws_subnet.bosh.cidr_block,0)}-${cidrhost(aws_subnet.bosh.cidr_block,6)}]"
    TF_BOSH_SUBNET_ID            = "${aws_subnet.bosh.id}"

    # Credhub UAA
    TF_CREDHUB_DNS_ENTRY = "${aws_route53_record.credhub.name}.${var.dns_domain_name}"
    TF_UAA_DNS_ENTRY     = "${aws_route53_record.uaa.name}.${var.dns_domain_name}"

    # Concourse
    TF_CONCOURSE_WEB_IP       = "${cidrhost(aws_subnet.concourse.cidr_block,5)}"
    TF_CONCOURSE_EXTERNAL_URL = "https://${aws_route53_record.concourse.name}.${var.dns_domain_name}"
    TF_DOMAIN_NAME            = "${var.dns_domain_name}"
    TF_CREDHUB_URL            = "https://${aws_route53_record.credhub.name}.${var.dns_domain_name}"

    # IAAS
    TF_LB_CA      = ""
    TF_LB_PUB_KEY = ""
  }
}
