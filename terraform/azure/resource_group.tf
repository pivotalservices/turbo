resource "azurerm_resource_group" "turbo" {
  name     = "${var.env_name}-turbo"
  location = "${var.arm_location}"

  tags {
    turbo = "${var.env_name}"
  }
}
