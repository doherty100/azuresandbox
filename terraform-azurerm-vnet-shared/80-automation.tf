# Azure automation account

resource "random_id" "random_id_automation_account_01_name" {
  byte_length = 8
}

resource "azurerm_automation_account" "automation_account_01" {
  name                = "autoacct-${random_id.random_id_automation_account_01_name.hex}-001"
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  sku_name            = "Basic"
  tags                = var.tags
}

output "automation_account_01_name" {
  value = azurerm_automation_account.automation_account_01.name
}

resource "azurerm_log_analytics_linked_service" "automation_account_01_link" {
  resource_group_name = azurerm_resource_group.resource_group_01.name
  workspace_name      = azurerm_log_analytics_workspace.log_analytics_workspace_01.name
  resource_id         = azurerm_automation_account.automation_account_01.id
  tags                = var.tags
}
