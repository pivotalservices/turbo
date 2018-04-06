resource "azurerm_managed_disk" "jumpbox_data" {
  name                 = "${var.env_name}-jumpbox-data"
  location             = "${azurerm_resource_group.turbo.location}"
  resource_group_name  = "${azurerm_resource_group.turbo.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  depends_on = ["azurerm_resource_group.turbo"]
}

resource "azurerm_public_ip" "jumpbox" {
  name                         = "${var.env_name}-jumpbox-pip"
  resource_group_name          = "${azurerm_resource_group.turbo.name}"
  location                     = "${azurerm_resource_group.turbo.location}"
  public_ip_address_allocation = "static"
  idle_timeout_in_minutes      = 30

  tags {
    turbo = "${var.env_name}"
  }

  depends_on = ["azurerm_resource_group.turbo"]
}

resource "azurerm_dns_a_record" "jumpbox" {
  name                = "jumpbox"
  zone_name           = "${azurerm_dns_zone.turbo.name}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.jumpbox.ip_address}"]
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.env_name}-jumpbox-nic"
  location            = "${azurerm_resource_group.turbo.location}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  ip_configuration {
    name                          = "${var.env_name}-jumpbox-ipconfig"
    subnet_id                     = "${azurerm_subnet.jumpbox.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox.id}"
  }

  tags {
    turbo = "${var.env_name}"
  }

  depends_on = ["azurerm_resource_group.turbo"]
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "${var.env_name}-jumpbox"
  location              = "${azurerm_resource_group.turbo.location}"
  resource_group_name   = "${azurerm_resource_group.turbo.name}"
  network_interface_ids = ["${azurerm_network_interface.jumpbox.id}"]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.env_name}-jumpbox-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.jumpbox_data.name}"
    managed_disk_id = "${azurerm_managed_disk.jumpbox_data.id}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.jumpbox_data.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${var.env_name}-jumpbox"
    admin_username = "${var.ssh_user}"

    custom_data = <<EOF
#!/usr/bin/env bash
while [ ! -e /dev/sdc ]; do sleep 1; done
if ! sudo file -sL /dev/sdc1 | grep ext4; then
    echo -e "g\nn\np\n1\n\n\nw" | sudo fdisk /dev/sdc
    sleep 10
    sudo mkfs.ext4 /dev/sdc1
fi
sudo mkdir /data
sudo mount /dev/sdc1 /data
if ! grep $(hostname) /etc/hosts; then
  echo "127.0.1.1" $(hostname) >> /etc/hosts
fi
EOF
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.ssh_user}/.ssh/authorized_keys"
      key_data = "${tls_private_key.jumpbox_ssh_private_key.public_key_openssh}"
    }
  }

  tags {
    turbo = "${var.env_name}"
  }
}

resource "azurerm_network_security_group" "jumpbox" {
  name                = "${var.env_name}-jumpbox"
  location            = "${azurerm_resource_group.turbo.location}"
  resource_group_name = "${azurerm_resource_group.turbo.name}"

  tags {
    turbo = "${var.env_name}"
  }

  depends_on = ["azurerm_resource_group.turbo"]
}

resource "azurerm_network_security_rule" "jumpbox-ssh" {
  name                        = "${var.env_name}-jumpbox-ssh-in-${count.index}"
  priority                    = "${200 + count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "${var.source_admin_networks[count.index]}"
  destination_address_prefix  = "*"
  network_security_group_name = "${azurerm_network_security_group.jumpbox.name}"
  resource_group_name         = "${azurerm_resource_group.turbo.name}"

  count = "${length(var.source_admin_networks)}"
}

resource "null_resource" "destroy-all" {
  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.turbo_home}/bosh/",
      "mkdir -p ${local.turbo_home}/bosh/",
    ]

    when = "destroy"
  }

  provisioner "file" {
    source      = "../../bosh/"
    destination = "${local.turbo_home}/bosh/"

    when = "destroy"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.turbo_home}/bosh/scripts/generic/bosh-delete-all.sh",
      "export TF_DEBUG=\"${var.debug}\"",
      "export TURBO_HOME=\"${local.turbo_home}\"",
      "export TERRAFORM_ENV=\"${local.env_base64}\"",
      "${local.turbo_home}/bosh/scripts/generic/bosh-delete-all.sh",
    ]

    when = "destroy"
  }

  connection {
    type        = "ssh"
    host        = "${local.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  # Used to destroy the jumpbox
  depends_on = [
    "azurerm_network_security_group.jumpbox",
    "azurerm_network_security_rule.jumpbox-ssh",
    "azurerm_virtual_machine.jumpbox",
    "azurerm_managed_disk.jumpbox_data",
    "azurerm_public_ip.jumpbox",
    "azurerm_subnet.bosh",
    "azurerm_subnet.concourse",
    "azurerm_network_security_rule.bosh_vms_all_local",
  ]
}
