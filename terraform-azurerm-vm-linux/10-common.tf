# Pinning to azurerm v2.43 while waiting for this issue to be resolved: https://github.com/terraform-providers/terraform-provider-azurerm/issues/10292 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.43.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}

data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.admin_username_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "log_analytics_workspace_key" {
  name         = var.log_analytics_workspace_id
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "storage_account_key" {
  name         = var.storage_account_name
  key_vault_id = var.key_vault_id
}

