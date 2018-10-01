locals {
  ssh_host   = "${azurerm_public_ip.jumpbox.ip_address}"
  jumpbox_id = "${azurerm_virtual_machine.jumpbox.id}"
}

locals {
  stemcell  = "bosh-azure-hyperv-ubuntu-trusty-go_agent"
  iaas_type = "azure"

  iaas_flags = {}
}

locals {
  arm_env_map = {
    public       = "AzureCloud"
    usgovernment = "AzureUSGovernment"
    german       = "AzureGermanCloud"
    china        = "AzureChinaCloud"
  }
}

locals {
  concourse_dns = "${azurerm_dns_a_record.concourse.name}.${var.dns_domain_name}"
  uaa_dns       = "${azurerm_dns_a_record.uaa.name}.${var.dns_domain_name}"
  credhub_dns   = "${azurerm_dns_a_record.credhub.name}.${var.dns_domain_name}"
  metrics_dns   = "${local.common_flags["metrics"] == "true" ? format("%s.%s", join("", azurerm_dns_a_record.metrics.*.name), var.dns_domain_name) : "" }"
}

locals {
  concourse_url = "https://${local.concourse_dns}"
  uaa_url       = "https://${local.uaa_dns}:${azurerm_lb_rule.uaa_https.frontend_port}"
  credhub_url   = "https://${local.credhub_dns}:${azurerm_lb_rule.credhub_https.frontend_port}"

  metrics_url = "${local.common_flags["metrics"] == "true" ? 
                    format("https://%s:%s", 
                        local.metrics_dns,
                        join("", azurerm_lb_rule.metrics_https.*.frontend_port))
                    : "" }"
}

locals {
  iaas_env = {
    TF_SSH_USER = "${var.ssh_user}"

    TF_ARM_TENANT_ID           = "${var.arm_tenant_id}"
    TF_ARM_SUBSCRIPTION_ID     = "${var.arm_subscription_id}"
    TF_ARM_CLIENT_ID           = "${var.arm_client_id}"
    TF_ARM_CLIENT_SECRET       = "${var.arm_client_secret}"
    TF_ARM_RESOURCE_GROUP_NAME = "${azurerm_resource_group.turbo.name}"
    TF_ARM_ENVIRONMENT         = "${lookup(local.arm_env_map, var.arm_location, "AzureCloud")}"
    TF_AZ_LIST                 = "[z1]"

    TF_INTERNAL_CIDR = "${azurerm_subnet.bosh.address_prefix}"
    TF_INTERNAL_GW   = "${cidrhost(azurerm_subnet.bosh.address_prefix,1)}"
    TF_INTERNAL_IP   = "${cidrhost(azurerm_subnet.bosh.address_prefix, 6)}"

    #Cloud Config
    TF_VNET_NAME  = "${azurerm_virtual_network.turbo.name}"
    TF_DEFAULT_SG = "${azurerm_network_security_group.bosh_default.name}"

    TF_BOSH_SUBNET_NAME          = "${azurerm_subnet.bosh.name}"
    TF_BOSH_SUBNET_RANGE         = "${azurerm_subnet.bosh.address_prefix}"
    TF_BOSH_SUBNET_GATEWAY       = "${cidrhost(azurerm_subnet.bosh.address_prefix,1)}"
    TF_BOSH_NETWORK_STATIC_IPS   = "[${cidrhost(azurerm_subnet.bosh.address_prefix,7)}-${cidrhost(azurerm_subnet.bosh.address_prefix,10)}]"
    TF_BOSH_NETWORK_RESERVED_IPS = "[${cidrhost(azurerm_subnet.bosh.address_prefix,0)}-${cidrhost(azurerm_subnet.bosh.address_prefix,6)}]"

    TF_CONCOURSE_SUBNET_NAME          = "${azurerm_subnet.concourse.name}"
    TF_CONCOURSE_SUBNET_RANGE         = "${azurerm_subnet.concourse.address_prefix}"
    TF_CONCOURSE_SUBNET_GATEWAY       = "${cidrhost(azurerm_subnet.concourse.address_prefix,1)}"
    TF_CONCOURSE_NETWORK_STATIC_IPS   = "[${cidrhost(azurerm_subnet.concourse.address_prefix,5)}-${cidrhost(azurerm_subnet.concourse.address_prefix,8)}]"
    TF_CONCOURSE_NETWORK_RESERVED_IPS = "[${cidrhost(azurerm_subnet.concourse.address_prefix,0)}-${cidrhost(azurerm_subnet.concourse.address_prefix,4)}]"

    TF_WEB_LB     = "${azurerm_lb.web_lb.name}"
    TF_WEB_SG     = "${azurerm_network_security_group.web.name}"
    TF_METRICS_LB = "${local.common_flags["metrics"] == "true" ? join(" ", azurerm_lb.metrics_lb.*.name) : "DUMMY"}"
    TF_METRICS_SG = "${local.common_flags["metrics"] == "true" ? join(" ", azurerm_network_security_group.metrics.*.name) : "DUMMY"}"

    # TF_CONCOURSE_WEB_LB = "${local.concourse_backend_service_name}"
    # TF_CREDHUB_LB       = "${local.credhub_backend_service_name}"

    #UCC Deployment
    TF_CREDHUB_DNS_ENTRY = "${local.credhub_dns}"
    TF_UAA_DNS_ENTRY     = "${local.uaa_dns}"
    TF_UAA_URL           = "${local.uaa_url}"
    # Concourse
    TF_CONCOURSE_EXTERNAL_URL = "${local.concourse_url}"
    TF_DOMAIN_NAME            = "${var.dns_domain_name}"
    TF_CREDHUB_URL            = "${local.credhub_url}"
    # Other
    TF_DB_STATIC_IP      = "${cidrhost(azurerm_subnet.concourse.0.address_prefix,6)}"
    TF_METRICS_STATIC_IP = "${cidrhost(azurerm_subnet.concourse.0.address_prefix,7)}"
    # IAAS
    TF_LB_CA      = ""
    TF_LB_PUB_KEY = ""
  }
}
