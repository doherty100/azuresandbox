# Azure quick start configuration: terraform-azurerm-vnet-spoke  

## Overview

This quick start implements the spoke portion of a basic hub-spoke networking topology and establishes bi-directional virtual network peering with the shared hub virtual network. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-hub](../terraform-azurerm-vnet-hub)

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 5 minutes
De-provisioning | ~10 minutes

### Getting started with default settings

This section describes how to provision this quick start using default settings.

* Run `./run-gen-tfvarsfile.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

### Getting started with custom settings

This section describes how to provision this quick start using custom settings. Refer to [Perform custom quick start deployment](https://github.com/doherty100/azurequickstarts#perform-custom-quick-start-deployment) for more details.

* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh`.
  * -v: Change to a custom *vnet_name* if desired.
  * -a: Change to a custom *vnet_address_space* if desired.
  * -s: Change to a custom *subnets* map if desired.
  * -t: Change to a custom *tags* map if desired.
  * Save changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

## Resource index

This section provides an index of the 10 resources included in this quick start.

### Virtual network

---

Dedicated spoke [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet). Note there are dependencies on this resource in the following quick starts:  

* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)
* [terraform-azurerm-vwan](../terraform-azurerm-vwan)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_name | Input | string | Local | vnet-spoke-001
vnet_address_space | Input | string | Local | 10.2.0.0/16
tags | Input  | map | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
vnet_spoke_01_id | output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-spoke-001
vnet_spoke_01_name | output | string | Global | vnet-spoke-001

#### Subnets

Shared hub virtual network [subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets). Note the following naming conventions used in the sample values are significant:

* A subnet named *snet-app-001* is required for use in other quick starts.
* A subnet named *snet-db-001* is required for use in other quick starts.
* A subnet named *snet-default-002* is required for use in other quick starts.
* A subnet named *AzureBastionSubnet* is required for the bastion resource described later.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
subnets | Input | map | Local | { snet-default-002 = "10.2.0.0/24", AzureBastionSubnet = "10.2.1.0/27", snet-db-001 = "10.2.1.32/27", snet-app-001 = "10.2.1.64/27" }
vnet_spoke_01_app_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-spoke-001/subnets/snet-app-001
vnet_spoke_01_db_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-spoke-001/subnets/snet-db-001
vnet_spoke_01_default_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-spoke-001/subnets/snet-default-002

#### Bastion

Dedicated [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) with an automatically generated random name following the grep format "bst-\[a-z0-9\]\{16\}-002" that is associated with the subnet *AzureBastionSubnet* as described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
bastion_host_02_dns_name | Output | string | Local | Obfuscated for security
bastion_host_02_id  | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/bastionHosts/bst-54ae94029797fd14-002
bastion_host_02_name | Output | string | Local | bst-54ae94029797fd14-002

##### Public ip

Dedicated standard static [public ip](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses) for use with bastion with an automatically generated name following the grep format "pip-\[a-z0-9\]\{16\}-002".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
public_ip_bastion_host_02_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/publicIPAddresses/pip-619c4233fe9c0bc0-002
public_ip_bastion_host_02_ip_address | Output | string | Local | Obfuscated for security
public_ip_bastion_host_02_name | Output | string | Local | pip-619c4233fe9c0bc0-002

#### Private DNS zone virtual network link

A link to the dedicated spoke virtual network is established with the shared private DNS zone *privatelink.file.core.windows.net* for use with the shared private endpoint resource in [terraform-azurerm-vnet-hub](../terraform-azurerm-vnet-hub).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_network_link_vnet_spoke_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net/virtualNetworkLinks/pdnslnk-vnet-spoke-001-002
virtual_network_link_vnet_spoke_01_name | Output | string | Local | pdnslnk-vnet-spoke-001-002

#### Virtual network peering

Bi-directional [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) is established between this virtual network and the shared hub virtual network.

##### Hub to spoke virtual network peering

This peering is between the shared hub virtual network and the dedicated spoke virtual network. The following arguments are enabled by default:

* [allow_virtual_network_access](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_virtual_network_access)
* [allow_forwarded_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_forwarded_traffic)
* [allow_gateway_transit](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_gateway_transit)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_hub_01_to_vnet_spoke_01_peering_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-hub-001/virtualNetworkPeerings/vnet_hub_01_to_vnet_spoke_01_peering
vnet_hub_01_to_vnet_spoke_01_peering_name | Output | string | Local | vnet_hub_01_to_vnet_spoke_01_peering

##### Spoke to hub virtual network peering

This peering is between the dedicated spoke virtual network and the shared hub virtual network. The following arguments are enabled by default:

* [allow_virtual_network_access](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_virtual_network_access)
* [allow_forwarded_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_network_peering.html#allow_forwarded_traffic)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_spoke_01_to_vnet_hub_01_peering_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-spoke-001/virtualNetworkPeerings/vnet_spoke_01_to_vnet_hub_01_peering
vnet_spoke_01_to_vnet_hub_01_peering_name | Output | string | Local | vnet_spoke_01_to_vnet_hub_01_peering

## Smoke testing

Explore newly provisioned resources in the Azure portal.

## Next steps

Move on to the next quick start [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows/) or [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux/).
