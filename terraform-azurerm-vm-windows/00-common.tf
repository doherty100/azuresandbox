# Provision a new Windows Server VM in Azure using an existing resource group, key vault, virtual network and subnet

# Note: Key vault secrets must be added prior to applying this configuration, see docs below.
# Providers used in this configuration

provider "azurerm" {
  version = "~> 1.33.0"
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}

# Get secrets from keyvault

# Name of local admin user for VM
data "azurerm_key_vault_secret" "adminpassword" {
  name         = "${var.vm_admin_password_secret}"
  key_vault_id = "${var.key_vault_id}"
}

# Password of local admin user for VM
data "azurerm_key_vault_secret" "adminuser" {
  name         = "${var.vm_admin_username_secret}"
  key_vault_id = "${var.key_vault_id}"
}

# Log analytics workspace key for monitoring vm extension. 
data "azurerm_key_vault_secret" "log_analytics_workspace_key" {
  name = "${var.log_analytics_workspace_id}" # Use the Log Analytics Workspace Id as the name of the secret 
  key_vault_id = "${var.key_vault_id}" 
}
