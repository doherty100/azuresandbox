# Linux virtual machine
resource "azurerm_linux_virtual_machine" "virtual_machine_02" {
  name                            = var.vm_name
  resource_group_name             = azurerm_network_interface.virtual_machine_02_nic_01.resource_group_name
  location                        = azurerm_network_interface.virtual_machine_02_nic_01.location
  size                            = var.vm_size
  admin_username                  = data.azurerm_key_vault_secret.adminuser.value
  network_interface_ids           = [azurerm_network_interface.virtual_machine_02_nic_01.id]
  tags                            = var.tags
  
  admin_ssh_key {
    username = data.azurerm_key_vault_secret.adminuser.value
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("${path.module}/cloud-init.yaml")
}

output "virtual_machine_02_id" {
  value = azurerm_linux_virtual_machine.virtual_machine_02.id
}

output "virtual_machine_02_name" {
  value = azurerm_linux_virtual_machine.virtual_machine_02.name
}

output "virtual_machine_02_principal_id" {
  value = azurerm_linux_virtual_machine.virtual_machine_02.identity[0].principal_id
}

# Nics
resource "azurerm_network_interface" "virtual_machine_02_nic_01" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_name}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

output "virtual_machine_02_nic_01_id" {
  value = azurerm_network_interface.virtual_machine_02_nic_01.id
}

output "virtual_machine_02_nic_01_name" {
  value = azurerm_network_interface.virtual_machine_02_nic_01.name
}

output "virtual_machine_02_nic_01_private_ip_address" {
  value = azurerm_network_interface.virtual_machine_02_nic_01.private_ip_addresses[0]
}
