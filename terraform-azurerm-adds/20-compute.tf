# Windows Server virtual machine
resource "azurerm_windows_virtual_machine" "virtual_machine_05" {
  name                     = var.vm_name
  resource_group_name      = azurerm_network_interface.virtual_machine_05_nic_01.resource_group_name
  location                 = azurerm_network_interface.virtual_machine_05_nic_01.location
  size                     = var.vm_size
  admin_username           = data.azurerm_key_vault_secret.adminuser.value
  admin_password           = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids    = [azurerm_network_interface.virtual_machine_05_nic_01.id]
  enable_automatic_updates = true
  patch_mode               = "AutomaticByPlatform"
  tags                     = merge(var.tags, { keyvault = var.key_vault_name })

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
}

output "virtual_machine_05_id" {
  value = azurerm_windows_virtual_machine.virtual_machine_05.id
}

output "virtual_machine_05_name" {
  value = azurerm_windows_virtual_machine.virtual_machine_05.name
}

output "virtual_machine_05_principal_id" {
  value = azurerm_windows_virtual_machine.virtual_machine_05.identity[0].principal_id
}

# Nics
resource "azurerm_network_interface" "virtual_machine_05_nic_01" {
  name                = "nic-${var.vm_name}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_name}-001"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

output "virtual_machine_05_nic_01_id" {
  value = azurerm_network_interface.virtual_machine_05_nic_01.id
}

output "virtual_machine_05_nic_01_name" {
  value = azurerm_network_interface.virtual_machine_05_nic_01.name
}

output "virtual_machine_05_nic_01_private_ip_address" {
  value = azurerm_network_interface.virtual_machine_05_nic_01.private_ip_addresses[0]
}

resource "azurerm_key_vault_access_policy" "key_vault_01_access_policy_virtual_machine_05_secrets_reader" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_windows_virtual_machine.virtual_machine_05.identity[0].tenant_id
  object_id    = azurerm_windows_virtual_machine.virtual_machine_05.identity[0].principal_id

  secret_permissions = [
    "get"
  ]
}

# Virtual machine extensions
resource "azurerm_virtual_machine_extension" "virtual_machine_05_postdeploy_script" {
  name                     = "vmext-${azurerm_windows_virtual_machine.virtual_machine_05.name}-postdeploy-script"
  virtual_machine_id       = azurerm_windows_virtual_machine.virtual_machine_05.id
  publisher                = "Microsoft.Compute"
  type                     = "CustomScriptExtension"
  type_handler_version     = "1.10"
  depends_on = [
    azurerm_key_vault_access_policy.key_vault_01_access_policy_virtual_machine_05_secrets_reader
  ]

  settings = <<SETTINGS
    {
      "fileUris": [ "${var.adds_vm_post_deploy_script_uri}", "${var.adds_vm_config_script_uri}" ],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"./${var.adds_vm_post_deploy_script_name}\" -Domain ${var.adds_domain_name}"
    }    
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${data.azurerm_key_vault_secret.storage_account_key.value}"
    }
  PROTECTED_SETTINGS
}
