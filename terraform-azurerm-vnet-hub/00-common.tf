# Provision a new hub virtual network and shared services in Azure including:
#   - Resource Group
#   - Virtual Network (hub)
#   - Storage account (blob storage)
#   - Key Vault
#   - Shared Image Gallery
#   - Log Analytics Workspace

# Providers used in this configuration

provider "azurerm" {
  version = "~> 1.33.0"
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}

provider "random" {
  version = "~> 2.2"
}