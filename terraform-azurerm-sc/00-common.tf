# Provision a new hub virtual network and shared services in Azure including:
#   - Resource Group
#   - Virtual Network (hub)
#   - Storage account (blob storage)
#   - Key Vault
#   - Shared Image Gallery
#   - Log Analytics Workspace
#   - Bastion host
#   - Security Center Standard

# Providers used in this configuration

provider "azurerm" {
  version = "~> 2.7"
  features {}
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}

provider "random" {
  version = "~> 2.2"
 }