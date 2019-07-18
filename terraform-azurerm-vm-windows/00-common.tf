# Provision a new Windows Server VM in Azure using an existing resource group, key vault, virtual network and subnet

# Providers used in this configuration

provider "azurerm" {
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}

# Get secrets from keyvault

data "azurerm_key_vault_secret" "adminuser" {
  name      = "${var.vm_admin_username_secret}"
  vault_uri = "${var.vault_uri}"
}

data "azurerm_key_vault_secret" "adminpassword" {
  name      = "${var.vm_admin_password_secret}"
  vault_uri = "${var.vault_uri}"
}

