# Shared log analytics workspace
resource "random_id" "random_id_log_analytics_workspace_01_name" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace_01" {
  name                = "log-${random_id.random_id_log_analytics_workspace_01_name.hex}-001"
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_workspace_retention_days
  tags                = var.tags
}

output "log_analytics_workspace_01_id" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.id
}

output "log_analytics_workspace_01_name" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.name
}

output "log_analytics_workspace_01_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.workspace_id
}

output "log_analytics_workspace_01_primary_shared_key" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.primary_shared_key
  sensitive = true
}
