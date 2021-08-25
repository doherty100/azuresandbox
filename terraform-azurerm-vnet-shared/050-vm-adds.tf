# AD DS virtual machine
resource "azurerm_windows_virtual_machine" "vm_adds" {
  name                     = var.vm_adds_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = var.vm_adds_size
  admin_username           = data.azurerm_key_vault_secret.adminuser.value
  admin_password           = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids    = [azurerm_network_interface.vm_adds_nic_01.id]
  enable_automatic_updates = true
  patch_mode               = "AutomaticByPlatform"
  tags                     = var.tags
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_adds_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_adds_image_publisher
    offer     = var.vm_adds_image_offer
    sku       = var.vm_adds_image_sku
    version   = var.vm_adds_image_version
  }
}

# Nics
resource "azurerm_network_interface" "vm_adds_nic_01" {
  name                = "nic-${var.vm_adds_name}-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_adds_name}-1"
    subnet_id                     = azurerm_subnet.vnet_shared_01_subnets["adds"].id
    private_ip_address_allocation = "Dynamic"
  }
}
