# resource "azurerm_public_ip" "natgw_public_ip" {
#   name                         = "${var.env_name}-natgw-public-ip"
#   location                     = "${azurerm_resource_group.turbo.location}"
#   resource_group_name          = "${azurerm_resource_group.turbo.name}"
#   public_ip_address_allocation = "static"
# }
# resource "azurerm_network_interface" "natgw_nic" {
#   name                 = "${var.env_name}-natgw-nic"
#   depends_on           = ["azurerm_public_ip.natgw_public_ip"]
#   location             = "${azurerm_resource_group.turbo.location}"
#   resource_group_name  = "${azurerm_resource_group.turbo.name}"
#   enable_ip_forwarding = true
#   ip_configuration {
#     name                          = "${var.env_name}-natgw-ip-config"
#     subnet_id                     = "${azurerm_subnet.jumpbox.id}"
#     private_ip_address_allocation = "dynamic"
#     public_ip_address_id          = "${azurerm_public_ip.natgw_public_ip.id}"
#   }
# }
# resource "azurerm_virtual_machine" "natgw" {
#   name                          = "${var.env_name}-natgw-vm"
#   depends_on                    = ["azurerm_network_interface.natgw_nic"]
#   location                      = "${azurerm_resource_group.turbo.location}"
#   resource_group_name           = "${azurerm_resource_group.turbo.name}"
#   network_interface_ids         = ["${azurerm_network_interface.natgw_nic.id}"]
#   vm_size                       = "Standard_DS1_v2"
#   delete_os_disk_on_termination = "true"
#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "natgw-osdisk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     os_type           = "linux"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "${var.env_name}-natgw"
#     admin_username = "${var.ssh_user}"
#     custom_data = <<EOF
# #!/usr/bin/env bash
# sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
# iptables -P FORWARD ACCEPT
# ETH=$(ip link show | grep "UP," | grep -v lo: | cut -d ":" -f 2 | sed -e 's/\ //g')
# iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
# EOF
#   }
#   os_profile_linux_config {
#     disable_password_authentication = true
#     ssh_keys {
#       path     = "/home/${var.ssh_user}/.ssh/authorized_keys"
#       key_data = "${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
#     }
#   }
#   tags {
#     turbo = "${var.env_name}"
#   }
# }
# resource "azurerm_route_table" "next_hop_natgw" {
#   name                = "${var.env_name}-next-hop-natgw"
#   location            = "${azurerm_resource_group.turbo.location}"
#   resource_group_name = "${azurerm_resource_group.turbo.name}"
# }
# resource "azurerm_route" "internet_fixed_ip" {
#   name                   = "${var.env_name}-internet-fixed-ip"
#   resource_group_name    = "${azurerm_resource_group.turbo.name}"
#   route_table_name       = "${azurerm_route_table.next_hop_natgw.name}"
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = "${azurerm_network_interface.natgw_nic.private_ip_address}"
# }

