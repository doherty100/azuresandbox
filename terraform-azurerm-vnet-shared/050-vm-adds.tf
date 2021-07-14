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
  # tags                     = merge(var.tags, { keyvault = var.key_vault_name })

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

  # identity {
  #   type = "SystemAssigned"
  # }
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

# resource "azurerm_key_vault_access_policy" "vm_adds_secrets_reader" {
#   key_vault_id = var.key_vault_id
#   tenant_id    = azurerm_windows_virtual_machine.vm_adds.identity[0].tenant_id
#   object_id    = azurerm_windows_virtual_machine.vm_adds.identity[0].principal_id

#   secret_permissions = [
#     "get"
#   ]
# }

# # Virtual machine extensions
# resource "azurerm_virtual_machine_extension" "vm_adds_postdeploy_script" {
#   name                       = "vmext-${azurerm_windows_virtual_machine.vm_adds.name}-postdeploy-script"
#   virtual_machine_id         = azurerm_windows_virtual_machine.vm_adds.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.10"
#   auto_upgrade_minor_version = true
#   # depends_on = [
#   #   azurerm_key_vault_access_policy.vm_adds_secrets_reader
#   # ]

#   settings = <<SETTINGS
#     {
#       "fileUris": [ "${var.vm_adds_post_deploy_script_uri}" ],
#       "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"./${var.vm_adds_post_deploy_script}\""
#     }    
#   SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#       "storageAccountName": "${var.storage_account_name}",
#       "storageAccountKey": "${data.azurerm_key_vault_secret.storage_account_key.value}"
#     }
#   PROTECTED_SETTINGS
# }
