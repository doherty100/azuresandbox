# Shared secrets

data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.vm_admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.vm_admin_username_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "log_analytics_workspace_key" {
  name         = var.log_analytics_workspace_id
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "storage_account_key" {
  name         = var.storage_account_name
  key_vault_id = var.key_vault_id
}

# Database server virtual machine

resource "azurerm_windows_virtual_machine" "virtual_machine_03" {
  name                  = var.vm_db_name
  resource_group_name   = azurerm_network_interface.virtual_machine_03_nic_01.resource_group_name
  location              = azurerm_network_interface.virtual_machine_03_nic_01.location
  size                  = var.vm_db_size
  admin_username        = data.azurerm_key_vault_secret.adminuser.value
  admin_password        = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids = [azurerm_network_interface.virtual_machine_03_nic_01.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_db_storage_replication_type
  }

  source_image_reference {
    publisher = var.vm_db_image_publisher
    offer     = var.vm_db_image_offer
    sku       = var.vm_db_image_sku
    version   = var.vm_db_image_version
  }
}

output "virtual_machine_03_id" {
  value = azurerm_windows_virtual_machine.virtual_machine_03.id
}

output "virtual_machine_03_name" {
  value = azurerm_windows_virtual_machine.virtual_machine_03.name
}

# Nics

resource "azurerm_network_interface" "virtual_machine_03_nic_01" {
  name                = "nic-${var.vm_db_name}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_db_name}-001"
    subnet_id                     = var.vm_db_subnet_id
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
  count                = var.vm_db_data_disk_count
  name                 = "dsk-${var.vm_db_name}-data_disk-${count.index + 1}"
  location             = azurerm_windows_virtual_machine.virtual_machine_03.location
  resource_group_name  = azurerm_windows_virtual_machine.virtual_machine_03.resource_group_name
  storage_account_type = var.vm_db_storage_replication_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_db_data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_03_data_disk_attachments" {
  count              = var.vm_db_data_disk_count
  managed_disk_id    = azurerm_managed_disk.virtual_machine_03_data_disks.*.id[count.index]
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine_03.id
  lun                = count.index
  caching            = "None"
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
  depends_on                 = [ azurerm_virtual_machine_data_disk_attachment.virtual_machine_03_data_disk_attachments ]

  settings = <<SETTINGS
    {
      "fileUris": [ "${var.vm_db_post_deploy_script_uri}" ],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"./${var.vm_db_post_deploy_script_name}\""
    }    
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${data.azurerm_key_vault_secret.storage_account_key.value}"
    }
  PROTECTED_SETTINGS
}

# Register with Microsoft.SqlVirtualMachine resource provider

resource "azurerm_mssql_virtual_machine" "virtual_machine_03_sql" {
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine_03.id
  sql_license_type = "PAYG"
  r_services_enabled = true
  sql_connectivity_port = 1433
  sql_connectivity_type = "PRIVATE"
  sql_connectivity_update_username = data.azurerm_key_vault_secret.adminuser.value
  sql_connectivity_update_password = data.azurerm_key_vault_secret.adminpassword.value
  depends_on = [ azurerm_virtual_machine_extension.virtual_machine_03_postdeploy_script ]

  auto_patching {
    day_of_week = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour = 2
  }
}

# Web server virtual machine

resource "azurerm_windows_virtual_machine" "virtual_machine_04" {
  name                  = var.vm_web_name
  resource_group_name   = azurerm_network_interface.virtual_machine_04_nic_01.resource_group_name
  location              = azurerm_network_interface.virtual_machine_04_nic_01.location
  size                  = var.vm_web_size
  admin_username        = data.azurerm_key_vault_secret.adminuser.value
  admin_password        = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids = [azurerm_network_interface.virtual_machine_04_nic_01.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_web_storage_replication_type
  }

  source_image_reference {
    publisher = var.vm_web_image_publisher
    offer     = var.vm_web_image_offer
    sku       = var.vm_web_image_sku
    version   = var.vm_web_image_version
  }
}

output "virtual_machine_04_id" {
  value = azurerm_windows_virtual_machine.virtual_machine_04.id
}

output "virtual_machine_04_name" {
  value = azurerm_windows_virtual_machine.virtual_machine_04.name
}

# Nic

resource "azurerm_network_interface" "virtual_machine_04_nic_01" {
  name                = "nic-${var.vm_web_name}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_web_name}-001"
    subnet_id                     = var.vm_web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

output "virtual_machine_04_nic_01_id" {
  value = azurerm_network_interface.virtual_machine_04_nic_01.id
}

output "virtual_machine_04_nic_01_name" {
  value = azurerm_network_interface.virtual_machine_04_nic_01.name
}

output "virtual_machine_04_nic_01_private_ip_address" {
  value = azurerm_network_interface.virtual_machine_04_nic_01.private_ip_addresses[0]
}

# Virtual machine extensions

resource "azurerm_virtual_machine_extension" "virtual_machine_04_extension_monitoring" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_04.name}-monitoring"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_04.id
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

resource "azurerm_virtual_machine_extension" "virtual_machine_04_extension_dependency" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_04.name}-dependency"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_04.id
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

resource "azurerm_virtual_machine_extension" "virtual_machine_04_postdeploy_script" {
  name                       = "vmext-${azurerm_windows_virtual_machine.virtual_machine_04.name}-postdeploy-script"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine_04.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  settings = <<SETTINGS
    {
      "fileUris": [ "${var.vm_web_post_deploy_script_uri}" ],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"./${var.vm_web_post_deploy_script_name}\""
    }    
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${data.azurerm_key_vault_secret.storage_account_key.value}"
    }
  PROTECTED_SETTINGS
}
