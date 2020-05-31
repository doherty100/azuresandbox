# Azure quick start configuration: terraform-azurerm-vwan  

## Overview

This quick start implements a shared virtual wan to connect the shared hub virtual network and the dedicated spoke virtual network to remote users and/or private networks. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-hub](../terraform-azurerm-vnet-hub)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~10 minutes
Smoke testing | ~5 minutes
De-provisioning | ~5 minutes

### Getting started with default settings

This section describes how to provision this quick start using default settings.

* Run `./run-gen-tfvarsfile.sh` to generate *terraform.tfvars*.  
* Run `terraform init`
* Run `terraform apply`

### Getting started with custom settings

This section describes how to provision this quick start using custom settings. Refer to [Perform custom quick start deployment](https://github.com/doherty100/azurequickstarts#perform-custom-quick-start-deployment) for more details.

* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh` to customize parameter values as needed and save changes.
  * -a: Change to a custom *vwan_hub_address_prefix* if desired.
  * -t: Change to a custom *tags* map if desired.
  * Save changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`
* Run `terraform apply`

## Resource index

This section provides an index of the 6 resources included in this quick start.

### Virtual wan

---

Shared [virtual wan](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) to connect the shared hub and dedicated spoke virtual networks to remote users and/or private networks with an automatically generated name following the grep format "vwan-\[a-z0-9\]\{16\}-001". The following arguments are configured by default:

* [disable_vpn_encryption](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#disable_vpn_encryption) = false
* [allow_branch_to_branch_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#allow_branch_to_branch_traffic) = true
* [allow_vnet_to_vnet_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#allow_vnet_to_vnet_traffic) = false

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | map | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
vwan_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualWans/vwan-e2b88962e7284da0-001
vwan_01_name | Output | string | Local | vwan-e2b88962e7284da0-001

#### Virtual wan hub

Shared [virtual wan hub](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) attached to the shared virtual wan with an automatically generated name following the grep format "vhub-\[a-z0-9\]\{16\}-001". Pre-configured [hub virtual network connections](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) are established with the shared hub virtual network and the dedicated spoke virtual network.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vwan_hub_address_prefix | Input | string | Local | 10.3.0.0/16
vwan_01_hub_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualHubs/vhub-6c8fe94d3b690bf9-001
vwan_01_hub_01_name | Output | string | Local | vhub-6c8fe94d3b690bf9-001

## Smoke testing

Explore newly provisioned resources in the Azure portal.

## Next steps

Connect the shared virtual wan hub to remote users via [point-to-site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/point-to-site-about) (P2S) and/or to private networks using [site-to-site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices) (S2S) or [ExpressRoute](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-introduction).
