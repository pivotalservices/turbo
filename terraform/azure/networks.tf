resource "azurerm_virtual_network" "turbo" {
  name                = "${var.env_name}-turbo-vnet"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  address_space       = ["${var.bootstrap_subnet}"]
  location            = "${azurerm_resource_group.turbo.location}"

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "${var.env_name}-jumpbox"
  resource_group_name  = "${azurerm_resource_group.turbo.name}"
  virtual_network_name = "${azurerm_virtual_network.turbo.name}"
  address_prefix       = "${cidrsubnet(var.bootstrap_subnet, 2, 0)}"
}

resource "azurerm_subnet" "bosh" {
  name                 = "${var.env_name}-bosh"
  resource_group_name  = "${azurerm_resource_group.turbo.name}"
  virtual_network_name = "${azurerm_virtual_network.turbo.name}"
  address_prefix       = "${cidrsubnet(var.bootstrap_subnet, 2, 1)}"

  # route_table_id = "${azurerm_route_table.next_hop_natgw.id}"
}

resource "azurerm_subnet" "concourse" {
  name                 = "${var.env_name}-concourse"
  resource_group_name  = "${azurerm_resource_group.turbo.name}"
  virtual_network_name = "${azurerm_virtual_network.turbo.name}"
  address_prefix       = "${cidrsubnet(var.bootstrap_subnet, 2, 2)}"

  # route_table_id = "${azurerm_route_table.next_hop_natgw.id}"
}
