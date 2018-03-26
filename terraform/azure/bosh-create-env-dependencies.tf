resource "null_resource" "bosh_iaas_specific_dependencies" {
  depends_on = [
    "azurerm_network_security_rule.bosh_vms_all_local",
  ]
}
