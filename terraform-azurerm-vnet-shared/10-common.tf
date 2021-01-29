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

output "subscription_id" {
  value = var.subscription_id
}

provider "random" {}
 