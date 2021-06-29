# Database server virtual machine
resource "azurerm_windows_virtual_machine" "virtual_machine_sql_01" {
  name                     = var.vm_db_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = var.vm_db_size
  admin_username           = data.azurerm_key_vault_secret.adminuser.value
  admin_password           = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids    = [azurerm_network_interface.virtual_machine_sql_01_nic_01.id]
  enable_automatic_updates = true
  patch_mode               = "AutomaticByOS"
  tags                     = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_db_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_db_image_publisher
    offer     = var.vm_db_image_offer
    sku       = var.vm_db_image_sku
    version   = var.vm_db_image_version
  }

  identity {
    type = "SystemAssigned"
  }
}

# Nics
resource "azurerm_network_interface" "virtual_machine_sql_01_nic_01" {
  name                = "nic-${var.vm_db_name}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_db_name}-001"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Data disks
resource "azurerm_managed_disk" "virtual_machine_sql_01_data_disks" {
  for_each = var.vm_db_data_disk_config

  name                 = "disk-${var.vm_db_name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.vm_db_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_sql_01_data_disk_attachments" {
  for_each = var.vm_db_data_disk_config

  managed_disk_id    = azurerm_managed_disk.virtual_machine_sql_01_data_disks[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine_sql_01.id
  lun                = each.value.lun
  caching            = each.value.caching
}

resource "azurerm_key_vault_access_policy" "key_vault_01_access_policy_virtual_machine_sql_01_secrets_reader" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_windows_virtual_machine.virtual_machine_sql_01.identity[0].tenant_id
  object_id    = azurerm_windows_virtual_machine.virtual_machine_sql_01.identity[0].principal_id

  secret_permissions = [
    "get"
  ]
}

# Virtual machine extensions
resource "azurerm_virtual_machine_extension" "virtual_machine_sql_01_postdeploy_script" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_sql_01.name}-postdeploy-script"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_sql_01.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  depends_on                 = [
    azurerm_virtual_machine_data_disk_attachment.virtual_machine_sql_01_data_disk_attachments,
    azurerm_key_vault_access_policy.key_vault_01_access_policy_virtual_machine_sql_01_secrets_reader ]

  settings = <<SETTINGS
    {
      "fileUris": [ "${var.vm_db_post_deploy_script_uri}", "${var.vm_db_sql_bootstrap_script_uri}", "${var.vm_db_sql_startup_script_uri}" ],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"./${var.vm_db_post_deploy_script}\""
    }    
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${data.azurerm_key_vault_secret.storage_account_key.value}"
    }
  PROTECTED_SETTINGS
}
