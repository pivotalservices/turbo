resource "azurerm_network_security_group" "bosh_default" {
  name                = "${var.env_name}-bosh-deployed-vms"
  location            = "${azurerm_resource_group.turbo.location}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  tags {
    turbo = "${var.env_name}"
  }

  depends_on = ["azurerm_resource_group.turbo"]
}

resource "azurerm_network_security_rule" "bosh_vms_all_local" {
  name                        = "${var.env_name}-bosh-deployed-vms-local"
  priority                    = "100"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = "${azurerm_network_security_group.bosh_default.name}"
  resource_group_name         = "${azurerm_resource_group.turbo.name}"
}
