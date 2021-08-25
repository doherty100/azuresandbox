# Azure quick start configuration: terraform-azurerm-vnet-spoke  

## Overview

This quick start implements the spoke portion of a basic hub-spoke networking topology and establishes bi-directional virtual network peering with the shared services virtual network. The spoke virtual network can be used for hosting solution infrastructure. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 5 minutes
De-provisioning | ~10 minutes

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 13 resources included in this quick start.

### Virtual network

---

Spoke [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) for hosting solution infrastructure. Note the following quick starts have dependencies on this quick start:  

* [terraform-azurerm-vm-sql](../terraform-azurerm-vm-sql)
* [terraform-azurerm-sql](../terraform-azurerm-sql)
* [terraform-azurerm-vwan](../terraform-azurerm-vwan)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_name | Input | string | Local | vnet-spoke-01
vnet_address_space | Input | string | Local | 10.2.0.0/16
vnet_spoke_01_id | output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01
vnet_spoke_01_name | output | string | Global | vnet-spoke-01

#### Subnets

The spoke virtual network is divided into [subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets). Note there are dependencies on the following subnets:

* An *application* subnet is required for deploying application server virtual machines in other quick starts.
* A *database* subnet is required for deploying database server virtual machines in other quick starts.
* An *AzureBastionSubnet* subnet is required for the bastion resource.
* A *PrivateLink* subnet is required for private endpoints created in other quick starts.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
subnets | Input | map | Local | { default = { name = "snet-default-02", address_prefix = "10.2.0.0/24", enforce_private_link_endpoint_network_policies = false }, AzureBastionSubnet = { name = "AzureBastionSubnet", address_prefix = "10.2.1.0/27", enforce_private_link_endpoint_network_policies = false }, PrivateLink = { name = "snet-storage-private-endpoints-02", address_prefix = "10.2.1.96/27", enforce_private_link_endpoint_network_policies = true }, database = { name = "snet-db-01", address_prefix = "10.2.1.32/27", enforce_private_link_endpoint_network_policies = false }, application = { name = "snet-app-01",address_prefix = "10.2.1.64/27", enforce_private_link_endpoint_network_policies = false } }
vnet_spoke_01_app_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01/subnets/snet-app-01
vnet_spoke_01_db_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01/subnets/snet-db-01
vnet_spoke_01_default_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01/subnets/snet-default-02
vnet_spoke_01_private_endpoints_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01/subnets/snet-storage-private-endpoints-02

#### Private DNS zone virtual network link

A link to the dedicated spoke virtual network is established with the shared private DNS zone *privatelink.file.core.windows.net* for use with the shared private endpoint resource in [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_network_link_vnet_spoke_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net/virtualNetworkLinks/pdnslnk-vnet-spoke-01-02
virtual_network_link_vnet_spoke_01_name | Output | string | Local | pdnslnk-vnet-spoke-01-02

#### Virtual network peering

Bi-directional [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) is established between this virtual network and the shared services virtual network.

##### Shared services to spoke virtual network peering

This peering is between the shared services virtual network and the dedicated spoke virtual network. The following arguments are enabled by default:

* [allow_virtual_network_access](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_virtual_network_access)
* [allow_forwarded_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_forwarded_traffic)
* [allow_gateway_transit](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_gateway_transit)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_shared_01_to_vnet_spoke_01_peering_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01/virtualNetworkPeerings/vnet_shared_01_to_vnet_spoke_01_peering
vnet_shared_01_to_vnet_spoke_01_peering_name | Output | string | Local | vnet_shared_01_to_vnet_spoke_01_peering

##### Spoke to shared services virtual network peering

This peering is between the dedicated spoke virtual network and the shared services virtual network. The following arguments are enabled by default:

* [allow_virtual_network_access](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_virtual_network_access)
* [allow_forwarded_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_forwarded_traffic)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_spoke_01_to_vnet_shared_01_peering_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01/virtualNetworkPeerings/vnet_spoke_01_to_vnet_shared_01_peering
vnet_spoke_01_to_vnet_shared_01_peering_name | Output | string | Local | vnet_spoke_01_to_vnet_shared_01_peering

## Smoke testing

Explore newly provisioned resources in the Azure portal.

## Next steps

Move on to the next quick start [terraform-azurerm-vm-sql](../terraform-azurerm-vm-sql).
