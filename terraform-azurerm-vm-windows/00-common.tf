# Provision a new Windows Server VM in Azure using an existing resource group, key vault, virtual network and subnet

# Providers used in this configuration

provider "azurerm" {
  version = "=1.33.0"
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}

# Get secrets from keyvault

data "azurerm_key_vault_secret" "adminpassword" {
  name         = "${var.vm_admin_password_secret}"
  key_vault_id = "${var.key_vault_id}"
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = "${var.vm_admin_username_secret}"
  key_vault_id = "${var.key_vault_id}"
}

data "azurerm_key_vault_secret" "log_analytics_workspace_key" {
  name = "${var.log_analytics_workspace_id}"
  key_vault_id = "${var.key_vault_id}"
}
