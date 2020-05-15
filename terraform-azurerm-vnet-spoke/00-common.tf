# Provision a new spoke virtual network in Azure using an existing resource group and hub virtual network

# Providers used in this configuration

provider "azurerm" {
  version = "~> 2.10"
  features {}
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}
