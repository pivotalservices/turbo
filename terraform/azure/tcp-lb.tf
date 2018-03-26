# Concourse Web
resource "azurerm_public_ip" "concourse_web_lb" {
  name                         = "${var.env_name}-concourse-web-lb"
  location                     = "${azurerm_resource_group.turbo.location}"
  resource_group_name          = "${azurerm_resource_group.turbo.name}"
  public_ip_address_allocation = "static"

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_dns_a_record" "concourse" {
  name                = "ci"
  zone_name           = "${azurerm_dns_zone.turbo.name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.concourse_web_lb.ip_address}"]
}

resource "azurerm_lb" "concourse_web_lb" {
  name                = "${var.env_name}-concourse-web-lb"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  location            = "${azurerm_resource_group.turbo.location}"

  frontend_ip_configuration {
    name                 = "${var.env_name}-ucc-frontend-ip-configuration"
    public_ip_address_id = "${azurerm_public_ip.concourse_web_lb.id}"
  }
}

resource "azurerm_lb_rule" "concourse_web_https" {
  name                = "${var.env_name}-concourse-web-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.concourse_web_lb.id}"

  frontend_ip_configuration_name = "${var.env_name}-ucc-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 443
  backend_port                   = 443

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.concourse_web.id}"
  probe_id                = "${azurerm_lb_probe.concourse_web_https.id}"
}

resource "azurerm_lb_probe" "concourse_web_https" {
  name                = "${var.env_name}-concourse-web-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.concourse_web_lb.id}"
  protocol            = "TCP"
  port                = 443
}

resource "azurerm_lb_backend_address_pool" "concourse_web" {
  name                = "${var.env_name}-concourse-web-backend-pool"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.concourse_web_lb.id}"
}

resource "azurerm_network_security_group" "concourse_web" {
  name                = "${var.env_name}-concourse-web"
  location            = "${azurerm_resource_group.turbo.location}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_network_security_rule" "concourse_web_https_in" {
  name                        = "${var.env_name}-concourse-web-https-in-${count.index}"
  priority                    = "${100 + count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "${var.source_admin_networks[count.index]}"
  destination_address_prefix  = "*"
  network_security_group_name = "${azurerm_network_security_group.concourse_web.name}"
  resource_group_name         = "${azurerm_resource_group.turbo.name}"

  count = "${length(var.source_admin_networks)}"
}

# resource "azurerm_network_security_rule" "concourse_web_https_in_self" {
#   name                        = "${var.env_name}-concourse-web-https-in-self"
#   priority                    = 300
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "TCP"
#   source_port_range           = "*"
#   destination_port_range      = "443"
#   source_address_prefix       = "${azurerm_public_ip.natgw_public_ip.ip_address}"
#   destination_address_prefix  = "*"
#   network_security_group_name = "${azurerm_network_security_group.concourse_web.name}"
#   resource_group_name         = "${azurerm_resource_group.turbo.name}"
# }

# Credhub UAA
resource "azurerm_public_ip" "credhub_uaa_lb" {
  name                         = "${var.env_name}-credhub-lb"
  location                     = "${azurerm_resource_group.turbo.location}"
  resource_group_name          = "${azurerm_resource_group.turbo.name}"
  public_ip_address_allocation = "static"

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_dns_a_record" "credhub" {
  name                = "credhub"
  zone_name           = "${azurerm_dns_zone.turbo.name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.credhub_uaa_lb.ip_address}"]
}

resource "azurerm_dns_a_record" "uaa" {
  name                = "uaa"
  zone_name           = "${azurerm_dns_zone.turbo.name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.credhub_uaa_lb.ip_address}"]
}

resource "azurerm_lb" "credhub_uaa_lb" {
  name                = "${var.env_name}-credhub-uaa-lb"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  location            = "${azurerm_resource_group.turbo.location}"

  frontend_ip_configuration {
    name                 = "${var.env_name}-ucc-frontend-ip-configuration"
    public_ip_address_id = "${azurerm_public_ip.credhub_uaa_lb.id}"
  }
}

resource "azurerm_lb_rule" "credhub_https" {
  name                = "${var.env_name}-credhub-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.credhub_uaa_lb.id}"

  frontend_ip_configuration_name = "${var.env_name}-ucc-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 8844
  backend_port                   = 8844

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.credhub.id}"
  probe_id                = "${azurerm_lb_probe.credhub_https.id}"
}

resource "azurerm_lb_probe" "credhub_https" {
  name                = "${var.env_name}-credhub-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.credhub_uaa_lb.id}"
  protocol            = "TCP"
  port                = 8844
}

resource "azurerm_lb_rule" "uaa_https" {
  name                = "${var.env_name}-uaa-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.credhub_uaa_lb.id}"

  frontend_ip_configuration_name = "${var.env_name}-ucc-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 8443
  backend_port                   = 8443

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.credhub.id}"
  probe_id                = "${azurerm_lb_probe.uaa_https.id}"
}

resource "azurerm_lb_probe" "uaa_https" {
  name                = "${var.env_name}-uaa-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.credhub_uaa_lb.id}"
  protocol            = "TCP"
  port                = 8443
}

resource "azurerm_lb_backend_address_pool" "credhub" {
  name                = "${var.env_name}-credhub-backend-pool"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.credhub_uaa_lb.id}"
}

resource "azurerm_network_security_group" "credhub_uaa" {
  name                = "${var.env_name}-credhub-uaa"
  location            = "${azurerm_resource_group.turbo.location}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_network_security_rule" "credhub_https_in" {
  name                        = "${var.env_name}-credhub-https-in-${count.index}"
  priority                    = "${100 + count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "8844"
  source_address_prefix       = "${var.source_admin_networks[count.index]}"
  destination_address_prefix  = "*"
  network_security_group_name = "${azurerm_network_security_group.credhub_uaa.name}"
  resource_group_name         = "${azurerm_resource_group.turbo.name}"

  count = "${length(var.source_admin_networks)}"
}

# resource "azurerm_network_security_rule" "credhub_https_in_self" {
#   name                        = "${var.env_name}-credhub-https-in-self"
#   priority                    = 310
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "TCP"
#   source_port_range           = "*"
#   destination_port_range      = "8444"
#   source_address_prefix       = "${azurerm_public_ip.natgw_public_ip.ip_address}"
#   destination_address_prefix  = "*"
#   network_security_group_name = "${azurerm_network_security_group.credhub_uaa.name}"
#   resource_group_name         = "${azurerm_resource_group.turbo.name}"
# }

resource "azurerm_network_security_rule" "uaa_https_in" {
  name                        = "${var.env_name}-uaa-https-in-${count.index}"
  priority                    = "${200 + count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = "${var.source_admin_networks[count.index]}"
  destination_address_prefix  = "*"
  network_security_group_name = "${azurerm_network_security_group.credhub_uaa.name}"
  resource_group_name         = "${azurerm_resource_group.turbo.name}"

  count = "${length(var.source_admin_networks)}"
}

# resource "azurerm_network_security_rule" "uaa_https_in_self" {
#   name                        = "${var.env_name}-uaa-https-in-self"
#   priority                    = 320
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "TCP"
#   source_port_range           = "*"
#   destination_port_range      = "8443"
#   source_address_prefix       = "${azurerm_public_ip.natgw_public_ip.ip_address}"
#   destination_address_prefix  = "*"
#   network_security_group_name = "${azurerm_network_security_group.credhub_uaa.name}"
#   resource_group_name         = "${azurerm_resource_group.turbo.name}"
# }

# Metrics
resource "azurerm_public_ip" "metrics_lb" {
  name                         = "${var.env_name}-metrics-lb"
  location                     = "${azurerm_resource_group.turbo.location}"
  resource_group_name          = "${azurerm_resource_group.turbo.name}"
  public_ip_address_allocation = "static"

  tags {
    turbo = "${var.env_name}"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "azurerm_dns_a_record" "metrics" {
  name                = "metrics"
  zone_name           = "${azurerm_dns_zone.turbo.name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.metrics_lb.ip_address}"]
}

resource "azurerm_lb" "metrics_lb" {
  name                = "${var.env_name}-metrics-lb"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  location            = "${azurerm_resource_group.turbo.location}"

  frontend_ip_configuration {
    name                 = "${var.env_name}-ucc-frontend-ip-configuration"
    public_ip_address_id = "${azurerm_public_ip.metrics_lb.id}"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "azurerm_lb_rule" "metrics_https" {
  name                = "${var.env_name}-metrics-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.metrics_lb.id}"

  frontend_ip_configuration_name = "${var.env_name}-ucc-frontend-ip-configuration"
  protocol                       = "TCP"
  frontend_port                  = 443
  backend_port                   = 3000

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.metrics.id}"
  probe_id                = "${azurerm_lb_probe.metrics_https.id}"

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "azurerm_lb_probe" "metrics_https" {
  name                = "${var.env_name}-metrics-https"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.metrics_lb.id}"
  protocol            = "TCP"
  port                = 3000

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "azurerm_lb_backend_address_pool" "metrics" {
  name                = "${var.env_name}-metrics-backend-pool"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  loadbalancer_id     = "${azurerm_lb.metrics_lb.id}"

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "azurerm_network_security_group" "metrics" {
  name                = "${var.env_name}-metrics"
  location            = "${azurerm_resource_group.turbo.location}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  tags {
    turbo = "${var.env_name}"
  }

  count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
}

resource "azurerm_network_security_rule" "metrics_https_in" {
  name                        = "${var.env_name}-metrics-https-in-${count.index}"
  priority                    = "${100 + count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "${var.source_admin_networks[count.index]}"
  destination_address_prefix  = "*"
  network_security_group_name = "${azurerm_network_security_group.metrics.name}"
  resource_group_name         = "${azurerm_resource_group.turbo.name}"

  count = "${local.common_flags["metrics"] == "true" ? length(var.source_admin_networks) : 0}"
}

# resource "azurerm_network_security_rule" "metrics_https_in_self" {
#   name                        = "${var.env_name}-metrics-https-in-self"
#   priority                    = 330
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "TCP"
#   source_port_range           = "*"
#   destination_port_range      = "3000"
#   source_address_prefix       = "${azurerm_public_ip.natgw_public_ip.ip_address}"
#   destination_address_prefix  = "*"
#   network_security_group_name = "${azurerm_network_security_group.metrics.name}"
#   resource_group_name         = "${azurerm_resource_group.turbo.name}"


#   count = "${local.common_flags["metrics"] == "true" ? 1 : 0}"
# }

