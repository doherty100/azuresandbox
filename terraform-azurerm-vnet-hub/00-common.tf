# Provision a new Windows Server VM in Azure using an existing resource group, key vault, virtual network and subnet

# Providers used in this configuration

provider "azurerm" {
    version = "=1.32.1"
  # subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
}
