# Database server virtual machine

resource "azurerm_windows_virtual_machine" "virtual_machine_03" {
  name                     = var.vm_db_name
  resource_group_name      = azurerm_network_interface.virtual_machine_03_nic_01.resource_group_name
  location                 = azurerm_network_interface.virtual_machine_03_nic_01.location
  size                     = var.vm_db_size
  admin_username           = data.azurerm_key_vault_secret.adminuser.value
  admin_password           = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids    = [azurerm_network_interface.virtual_machine_03_nic_01.id]
  enable_automatic_updates = true
  tags                     = merge(var.tags, { keyvault = var.key_vault_name })

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

output "virtual_machine_03_id" {
  value = azurerm_windows_virtual_machine.virtual_machine_03.id
}

output "virtual_machine_03_name" {
  value = azurerm_windows_virtual_machine.virtual_machine_03.name
}

output "virtual_machine_03_principal_id" {
  value = azurerm_windows_virtual_machine.virtual_machine_03.identity[0].principal_id
}

# Nics

resource "azurerm_network_interface" "virtual_machine_03_nic_01" {
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

output "virtual_machine_03_nic_01_id" {
  value = azurerm_network_interface.virtual_machine_03_nic_01.id
}

output "virtual_machine_03_nic_01_name" {
  value = azurerm_network_interface.virtual_machine_03_nic_01.name
}

output "virtual_machine_03_nic_01_private_ip_address" {
  value = azurerm_network_interface.virtual_machine_03_nic_01.private_ip_addresses[0]
}

# Data disks

resource "azurerm_managed_disk" "virtual_machine_03_data_disks" {
  for_each = var.vm_db_data_disk_config

  name                 = "disk-${var.vm_db_name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.vm_db_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_03_data_disk_attachments" {
  for_each = var.vm_db_data_disk_config

  managed_disk_id    = azurerm_managed_disk.virtual_machine_03_data_disks[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine_03.id
  lun                = each.value.lun
  caching            = each.value.caching
}

# Register with Microsoft.SqlVirtualMachine resource provider

resource "azurerm_mssql_virtual_machine" "virtual_machine_03_sql" {
  virtual_machine_id               = azurerm_windows_virtual_machine.virtual_machine_03.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_username = data.azurerm_key_vault_secret.adminuser.value
  sql_connectivity_update_password = data.azurerm_key_vault_secret.adminpassword.value
  tags                             = var.tags
  depends_on                       = [azurerm_virtual_machine_data_disk_attachment.virtual_machine_03_data_disk_attachments]

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }
}

# Key vault access policy
resource "azurerm_key_vault_access_policy" "key_vault_01_access_policy_virtual_machine_03_secrets_reader" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_windows_virtual_machine.virtual_machine_03.identity[0].tenant_id
  object_id    = azurerm_windows_virtual_machine.virtual_machine_03.identity[0].principal_id

  secret_permissions = [
    "get"
  ]
}

# Virtual machine extensions

resource "azurerm_virtual_machine_extension" "virtual_machine_03_extension_monitoring" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_03.name}-monitoring"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_03.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  settings           = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
    SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${data.azurerm_key_vault_secret.log_analytics_workspace_key.value}"
    }
    PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "virtual_machine_03_extension_dependency" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_03.name}-dependency"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_03.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  settings           = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
    SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${data.azurerm_key_vault_secret.log_analytics_workspace_key.value}"
    }
    PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "virtual_machine_03_postdeploy_script" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_03.name}-postdeploy-script"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_03.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  tags                       = var.tags
  depends_on                 = [azurerm_mssql_virtual_machine.virtual_machine_03_sql]

  settings = <<SETTINGS
    {
      "fileUris": [ "${var.vm_db_post_deploy_script_uri}", "${var.vm_db_sql_startup_script_uri}" ],
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
