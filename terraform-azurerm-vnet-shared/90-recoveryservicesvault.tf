# Recovery services vault for same region backups
resource "random_id" "random_id_recovery_services_vault_01_name" {
  byte_length = 8
}

resource "azurerm_recovery_services_vault" "recovery_services_vault_01" {
  name                = "rsv-${random_id.random_id_recovery_services_vault_01_name.hex}-001"
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

output "recovery_services_vault_01_id" {
  value = azurerm_recovery_services_vault.recovery_services_vault_01.id
}

output "recovery_services_vault_01_name" {
  value = azurerm_recovery_services_vault.recovery_services_vault_01.name
}

output "recovery_services_vault_01_principal_id" {
  value = azurerm_recovery_services_vault.recovery_services_vault_01.identity[0].principal_id
}
