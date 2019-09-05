resource "azurerm_log_analytics_workspace" "log_analytics_workspace_01" {
  name                = "${var.log_analytics_workspace_name}"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  sku                 = "PerGB2018"
  retention_in_days   = "${var.log_analytics_workspace_retention_days}"
  tags                = "${var.tags}"
}

output "log_analytics_workspace_01_id" {
  value = "${azurerm_log_analytics_workspace.log_analytics_workspace_01.id}"
}
