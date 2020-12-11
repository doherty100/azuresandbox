# Azure quick start configuration: terraform-azurerm-vwan  

## Overview

This quick start implements a shared virtual wan to connect the shared services virtual network and the dedicated spoke virtual network to remote users and/or private networks. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~10 minutes
Smoke testing | ~5 minutes
De-provisioning | ~5 minutes

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 6 resources included in this quick start.

### Virtual wan

---

Shared [virtual wan](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) to connect the shared services and dedicated spoke virtual networks to remote users and/or private networks with an automatically generated name following the grep format "vwan-\[a-z0-9\]\{16\}-001". The following arguments are configured by default:

* [disable_vpn_encryption](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#disable_vpn_encryption) = false
* [allow_branch_to_branch_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#allow_branch_to_branch_traffic) = true

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vwan_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualWans/vwan-e2b88962e7284da0-001
vwan_01_name | Output | string | Local | vwan-e2b88962e7284da0-001

#### Virtual wan hub

Shared [virtual wan hub](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) attached to the shared virtual wan with an automatically generated name following the grep format "vhub-\[a-z0-9\]\{16\}-001". Pre-configured [hub virtual network connections](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) are established with the shared services virtual network and the dedicated spoke virtual network.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vwan_hub_address_prefix | Input | string | Local | 10.3.0.0/16
vwan_01_hub_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualHubs/vhub-6c8fe94d3b690bf9-001
vwan_01_hub_01_name | Output | string | Local | vhub-6c8fe94d3b690bf9-001

## Smoke testing

Explore newly provisioned resources in the Azure portal.

## Next steps

Connect the shared virtual wan hub to remote users via [point-to-site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/point-to-site-about) (P2S) and/or to private networks using [site-to-site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices) (S2S) or [ExpressRoute](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-introduction).
