# \#AzureQuickStarts - terraform-azurerm-vnet-app

## Overview

![vnet-app-diagram](./vnet-app-diagram.png)

This quick start implements a virtual network for applications including:

* A virtual network for hosting application infrastructure and services
  * [Virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) is enabled with the shared services virtual network
* An [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) database server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [SQL Server virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview#payasyougo) offering

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 5 minutes
De-provisioning | ~10 minutes

## Before you start

The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Smoke testing

Explore newly provisioned resources in the Azure portal.

## Documentation

This section provides additional information on various aspects of this quick start.

### Bootstrap script

This quick start uses the script [./bootstrap.sh] to create a *terraform.tfvars* file for generating and applying Terraform plans. For simplified deployment, several runtime defaults are initialized using output variables stored the *terraform.tfstate* associated with the [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared) quick start, including:

Output variable | Sample value
--- | ---
aad_tenant_id | "00000000-0000-0000-0000-000000000000"
adds_domain_name | "mytestlab.local"
admin_password_secret | "adminpassword"
admin_username_secret | "adminuser"
arm_client_id | "00000000-0000-0000-0000-000000000000"
automation_account_name | "auto-9a633c2bba9351cc-01"
dns_server | "10.1.2.4"
key_vault_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.KeyVault/vaults/kv-XXXXXXXXXXXXXXX"
key_vault_name | "kv-XXXXXXXXXXXXXXX"
location | "eastus2"
resource_group_name | "rg-vdc-nonprod-01"
storage_account_name | "stXXXXXXXXXXXXXXX"
storage_container_name | "scripts"
subscription_id | "00000000-0000-0000-0000-000000000000"
tags | tomap( { "costcenter" = "10177772" "environment" = "dev" "project" = "#AzureQuickStarts" } )
vnet_shared_01_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01""
vnet_shared_01_name | "vnet-shared-01"

### Terraform Resources

This section lists the resources included in the Terraform configurations in this quick start.

#### Network resources

The configuration for these resources can be found in [020-network.tf](./020-network.tf).

Resource name (ARM) | Notes
--- | ---

## Next steps

Move on to the next quick start [terraform-azurerm-sql](../terraform-azurerm-sql).
