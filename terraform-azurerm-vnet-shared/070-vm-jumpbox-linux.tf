# Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm_jumpbox_linux" {
  name                  = var.vm_jumpbox_linux_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_jumpbox_linux_size
  admin_username        = data.azurerm_key_vault_secret.adminuser.value
  network_interface_ids = [azurerm_network_interface.vm_jumbox_linux_nic_01.id]
  # enable_automatic_updates = true
  # patch_mode               = "AutomaticByPlatform"
  # See https://github.com/hashicorp/terraform-provider-azurerm/issues/13257 
  tags       = merge(var.tags, { keyvault = var.key_vault_name })
  depends_on = [azurerm_windows_virtual_machine.vm_adds]

  admin_ssh_key {
    username   = data.azurerm_key_vault_secret.adminuser.value
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_jumpbox_linux_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_jumpbox_linux_image_publisher
    offer     = var.vm_jumpbox_linux_image_offer
    sku       = var.vm_jumpbox_linux_image_sku
    version   = var.vm_jumpbox_linux_image_version
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("${path.root}/${var.vm_jumpbox_linux_userdata_file}")
}

# Nics
resource "azurerm_network_interface" "vm_jumbox_linux_nic_01" {
  name                = "nic-${var.vm_jumpbox_linux_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_jumpbox_linux_name}"
    subnet_id                     = azurerm_subnet.vnet_shared_01_subnets["default"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_key_vault_access_policy" "vm_jumpbox_linux_secrets_reader" {
  key_vault_id       = var.key_vault_id
  tenant_id          = azurerm_linux_virtual_machine.vm_jumpbox_linux.identity[0].tenant_id
  object_id          = azurerm_linux_virtual_machine.vm_jumpbox_linux.identity[0].principal_id
  secret_permissions = ["get", "list"]
}
