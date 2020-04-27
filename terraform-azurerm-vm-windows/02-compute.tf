# Create compute related dependencies

# Create OS disk

resource "azurerm_windows_virtual_machine" "vm1" {
  name                          = var.vm_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  size                       = var.vm_size
  admin_username = data.azurerm_key_vault_secret.adminuser.value
  admin_password = data.azurerm_key_vault_secret.adminpassword.value
  network_interface_ids         = [azurerm_network_interface.nic1.id]
  tags                          = var.tags

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = var.vm_storage_replication_type
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}

resource "azurerm_managed_disk" "datadisk" {
  count                = var.vm_data_disk_count
  name                 = "${var.vm_name}-datadisk${count.index + 1}"
  location             = azurerm_windows_virtual_machine.vm1.location
  resource_group_name  = azurerm_windows_virtual_machine.vm1.resource_group_name
  storage_account_type = var.vm_storage_replication_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "external" {
  count              = var.vm_data_disk_count
  managed_disk_id    = azurerm_managed_disk.datadisk.*.id[count.index]
  virtual_machine_id = azurerm_windows_virtual_machine.vm1.id
  lun                = count.index
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "vm1_extension_monitoring" {
  name                       = "${azurerm_windows_virtual_machine.vm1.name}-monitoring"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm1.id
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

resource "azurerm_virtual_machine_extension" "vm1_extension_dependency" {
  name                       = "${azurerm_windows_virtual_machine.vm1.name}-dependency"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm1.id
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

output vm1_id {
  value = azurerm_windows_virtual_machine.vm1.id
}