resource "azurerm_dns_zone" "turbo" {
  name                = "${var.dns_domain_name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_dns_ns_record" "turbo" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.turbo.name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  ttl                 = 300

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[0]}"
  }

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[1]}"
  }

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[2]}"
  }

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[3]}"
  }

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_dns_ns_record" "turbo_master" {
  name                = "${replace(var.dns_domain_name, format(".%s", var.master_dns_domain_name), "")}"
  zone_name           = "${var.master_dns_domain_name}"
  resource_group_name = "${var.master_dns_domain_name_rg}"
  ttl                 = 300

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[0]}"
  }

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[1]}"
  }

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[2]}"
  }

  record {
    nsdname = "${azurerm_dns_zone.turbo.name_servers[3]}"
  }

  tags {
    turbo = "${var.env_name}"
  }
}
