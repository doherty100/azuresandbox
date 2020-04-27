resource "azurerm_security_center_subscription_pricing" "sc-prc-1" {
  tier = "Standard"
}

resource "azurerm_security_center_workspace" "sc-law-1" {
  scope        = var.security_center_scopeye
  workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_01.id

  timeouts {
    create = "1h30m"
    delete = "1h30m"
  }
}
