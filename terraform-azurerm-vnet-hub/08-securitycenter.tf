resource "azurerm_security_center_subscription_pricing" "sc-prc-1" {
    tier = "Standard"
}

resource "azurerm_security_center_workspace" "sc-law-1" {
    scope = var.security_center_scope
    workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_01.id
}