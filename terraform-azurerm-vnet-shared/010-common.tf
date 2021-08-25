# Providers
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "random" {}

# Secrets
data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.admin_username_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "storage_account_key" {
  name         = var.storage_account_name
  key_vault_id = var.key_vault_id
}

# Output variables
output "key_vault_id" {
  value = var.key_vault_id
}

output "key_vault_name" {
  value = var.key_vault_name
}

output "location" {
  value = var.location
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "storage_account_name" {
  value = var.storage_account_name
}

output "subscription_id" {
  value = var.subscription_id
}
