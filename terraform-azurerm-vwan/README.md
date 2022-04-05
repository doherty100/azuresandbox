# \#AzureSandbox - terraform-azurerm-vwan  

![vnet-shared-diagram](./vwan-diagram.drawio.svg)

## Contents

* [Overview](#overview)
* [Before you start](#before-you-start)
* [Getting started](#getting-started)
* [Smoke testing](#smoke-testing)
* [Documentation](#documentation)
* [Next steps](#next-steps)

## Overview

This configuration implements [Azure Virtual WAN](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) to connect the sandbox to remote users and/or private networks.

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~20 minutes
Smoke testing | ~45 minutes

## Before you start

The following configurations must be deployed first before starting:

* [terraform-azurerm-vnet-app](../terraform-azurerm-vnet-app)

## Getting started

This section describes how to provision this configuration using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Smoke testing

These smoke tests are designed to be performed from a Windows client over a P2S VPN connection to the Azure Virtual WAN Hub. Upon completion you will have tested connectivity using a variety of ports and protocols to Azure resources using private IP addresses.

### Test Point to Site (P2S) VPN Connectivity

This test establishes a Point to Site (P2S) VPN connection to the Virtual Wan Hub using the [Azure VPN Client](https://www.microsoft.com/store/productId/9NP355QT2SQB) as described in [Tutorial: Create a User VPN connection using Azure Virtual WAN](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-point-to-site-portal), then tests connectivity to various Azure resources using private endpoints.

* Generate self-signed certificates to use for P2S VPN certificate authentication.
  * Using the Windows client you intend to test connectivity with, generate the certificates required for setting up a P2S VPN using [genp2svpncerts.ps1](./genp2svpncerts.ps1). This script creates a root certificate in the registry, then uses that root certificate to create a self-signed client certificate in the registry. Both certificates are then exported to files:
    * `MyP2SVPNRootCert_DER_Encoded.cer`: This is a temporary file used to create a Base64 encoded version of the root certificate.
    * `MyP2SVPNRootCert_Base64_Encoded.cer`: This is the root certificate used to create a User VPN Configuration in Virtual WAN.
    * `MyP2SVPNChildCert.pfx`: This is an export of the client certificate protected with a password. You only need this if you want to configure the Azure VPN client on a different computer than the one used to generate the certificates.
  * Make a note of the CN for the root certificate, the default is `MyP2SVPNRootCert`.
* Create a User VPN Configuration as described in [Create a P2S configuration](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-point-to-site-portal#p2sconfig).
  * Configuration name: `UserVPNConfig1`
  * Tunnel type: `OpenVPN`
  * Authentication method: `Azure certificate`
  * ROOT CERTIFICATE NAME: `MyP2SVPNRootCert` (default)
  * PUBLIC CERTIFICATE DATA: Paste in the content of `MyP2SVPNRootCert_Base64_Encoded.cer`.
    * Note: **Do not include** the begin / end certificate lines.
* Create User (P2S) VPN Gateway. This can take up to 15 minutes.
  * In the Azure Portal, navigate to *Home > Virtual WANs > vwan-XXXX-01 > Hubs > vhub-XXXX-01 > User VPN (Point to site) > Create User VPN Gateway*
  * Gateway scale units: `1 scale unit`
  * Point to site configuration: `UserVPNConfig1`
  * Routing preference: `Microsoft network`
  * Use Remote/On-premises RADIUS server: `Disabled`
  * Client address pool: `10.4.0.0/16`
  * Custom DNS servers: `10.1.1.4` and `168.63.129.16` (See [What is IP address 168.63.129.16?](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) for more info)
* Download Virtual Hub User VPN Profile
  * In the Azure Portal, navigate to *Home > Virtual WANs > vwan-XXXX-01 > Hubs > vhub-XXXX-01 > User VPN (Point to site)*
  * Click *Download virtual Hub User VPN profile*
    * Authentication type: *EAPTLS*
    * Click *Generate and download profile*
    * Extract the files from the archive and examine `AzureVPN\azurevpnconfig.xml`.
* Install and configure VPN Client
  * Install the [Azure VPN Client](https://www.microsoft.com/store/productId/9NP355QT2SQB).
  * Launch the Azure VPN Client
  * Navigate to *+ Add or Import a new VPN connection*
  * Click *Import*
  * Navigate to the `AzureVPN` folder from the previous step, and open `azurevpnconfig.xml`.
    * Client authentication
      * Authentication Type: *Certificate*
      * Certificate Information: `MyP2SVPNChildCert` (Note: If you do not see this certificate you need to import the .pfx created in a previous step)
  * Click *Save*
  * Connect and inspect routes. If you went with the default configuration you should see these address ranges:
    * `10.1.0.0/16`: Shared services virtual network
    * `10.2.0.0/16`: Application virtual network
  * Test RDP (port 3389) connectivity using private IP address (not bastion)
    * From a PowerShell Command prompt, enter `Resolve-DnsName jumpwin1.mysandbox.local`.
    * Verify the IP address returned is in the *azurerm_subnet.vnet_app_01_subnets["snet-app-01"]* subnet.
      * Note: This DNS query was resolved by the DNS server running on *azurerm_windows_virtual_machine.vm_adds*.
    * Launch *Remote Desktop Connection* (`mstsc.exe`) and connect to `jumpwin1.mysandbox.local` using the credentials `bootstrapadmin@mysandbox.local`.
  * Test SSH (port 22) connectivity using private IP address (not bastion)
    * From a PowerShell Command prompt, enter `Resolve-DnsName jumplinux1.mysandbox.local`.
    * Verify the IP address returned is in the *azurerm_subnet.vnet_app_01_subnets["snet-app-01"]* subnet.
      * Note: This DNS query was resolved by the DNS server running on *azurerm_windows_virtual_machine.vm_adds*.
    * From a PowerShell command prompt, establish an SSH connection to *jumplinux1.mysandbox.local* using the command `ssh bootstrapadmin@mysandbox.local@jumplinux1`
  * Test SMB (port 445) connectivity to private IP address
    * Test DNS queries for Azure Files private endpoint (PaaS)
      * Navigate to *portal.azure.com* > *Storage accounts* > *stxxxxxxxxxxx* > *File shares* > *myfileshare* > *Settings* > *Properties* and copy the the FQDN portion of the URL, e.g. *stxxxxxxxxxxx.file.core.windows.net*.
      * Using PowerShell, run the command `Resolve-DnsName stxxxxxxxxxxx.file.core.windows.net`.
      * Verify the *IP4Address* returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-privatelink-01"]*, e.g. `10.2.2.*`.
        * Note: This DNS query is resolved using *azurerm_private_dns_zone_virtual_network_link.file_core_windows_net_to_vnet_shared_01* and *azurerm_private_dns_a_record.storage_account_01_file*.
    * Test SMB connectivity with Windows Authentication to Azure Files private endpoint (PaaS)
      * Open a Windows command prompt and enter the following command: `net use z: \\stxxxxxxxxxxx.file.core.windows.net\myfileshare /USER:bootstrapadmin@mysandbox.local`. Enter the correct password when prompted.
      * Create some test files and folders on the newly mapped Z: drive.
      * Unmap the z: drive using the command `net use z: /d`.
  * Test DNS queries for SQL Server (IaaS)
    * Using PowerShell, run the command `Resolve-DnsName mssqlwin1.mysandbox.local`.
    * Verify the IPAddress returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-db-01"]*, e.g. `10.2.1.*`.
      * Note: This DNS query is resolved by the DNS Server running on *azurerm_windows_virtual_machine.vm_adds*.
  * Test TDS (port 1433) connectivity to Database server virtual machine
    * Install [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) if needed.
    * Navigate to *Start* > *Microsoft SQL Server Tools 18* > *Microsoft SQL Server Management Studio 18*
    * Connect to the default instance of SQL Server installed on the database server virtual machine using the following values:
      * Server name: *mssqlwin1.mysandbox.local*
      * Authentication: *SQL Server Authentication*
        * Login: `sa`
        * Password: Use the value of the `adminpassword` secret in key vault.
        * Options:
          * Encrypt connection: disabled
      * Note: **Windows Authentication cannot be used** because your client machine is not domain joined to the `mysandbox.local` domain.
      * Note: **Encryption must be disabled** because your client machine does not trust the `mysandbox.local` domain. See [SSL Security Error with Data Source](https://powerbi.microsoft.com/en-us/blog/ssl-security-error-with-data-source) for more details.
    * Expand the *Databases* tab and verify you can see *testdb*
  * Test DNS queries for Azure SQL database private endpoint (PaaS)
    * Navigate to *portal.azure.com* > *SQL Servers* > *mssql-xxxxxxxxxxxxxxxx* > *Properties* > *Server name* and and copy the the FQDN, e.g. *mssql&#x2011;xxxxxxxxxxxxxxxx.database.windows.net*.
    * Using PowerShell, run the command `Resolve-DnsName mssql-xxxxxxxxxxxxxxxx.database.windows.net`.
    * Verify the *IP4Address* returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-privatelink-01"]*, e.g. `10.2.2.*`.
      * Note: This DNS query is resolved using *azurerm_private_dns_zone_virtual_network_link.database_windows_net_to_vnet_shared_01* and *azurerm_private_dns_a_record.sql_server_01*.
  * Test TDS (port 1433) connectivity to Azure SQL Database using PrivateLink
    * Navigate to *Start* > *Microsoft SQL Server Tools 18* > *Microsoft SQL Server Management Studio 18*
    * Connect to the Azure SQL Database server using PrivateLink
      * Server name: *mssql&#x2011;xxxxxxxxxxxxxxxx.database.windows.net*
      * Authentication: *SQL Server Authentication*
      * Login: *bootstrapadmin*
      * Password: Use the value stored in the *adminpassword* key vault secret
    * Expand the *Databases* tab and verify you can see *testdb*

## Documentation

This section provides additional information on various aspects of this configuration.

### Bootstrap script

This configuration uses the script [bootstrap.sh](./bootstrap.sh) to create a *terraform.tfvars* file for generating and applying Terraform plans. For simplified deployment, several runtime defaults are initialized using output variables stored in the *terraform.tfstate* files associated with the [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared) and [terraform-azurerm-vnet-app](../terraform-azurerm-vnet-app) configurations, including:

Output variable | Sample value
--- | ---
aad_tenant_id | "00000000-0000-0000-0000-000000000000"
arm_client_id | "00000000-0000-0000-0000-000000000000"
location | "eastus"
resource_group_name | "rg-sandbox-01"
subscription_id | "00000000-0000-0000-0000-000000000000"
tags | tomap( { "costcenter" = "10177772" "environment" = "dev" "project" = "#AzureSandbox" } )
vnet_shared_01_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sandbox-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01"
vnet_shared_01_name | "vnet-shared-01"
vnet_app_01_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sandbox-01/providers/Microsoft.Network/virtualNetworks/vnet-app-01"
vnet_app_01_name | "vnet-app-01"

### Terraform Resources

This section lists the resources included in this configuration.

#### Network resources

The configuration for these resources can be found in [020-network.tf](./020-network.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_virtual_wan.vwan_01 (vwan-xxxxxxxxxxxxxxxx-01)| [Virtual wan](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) to connect the shared services and application virtual networks to remote users.
azurerm_virtual_hub.vwan_01_hub_01 (vhub-xxxxxxxxxxxxxxxx-01) | [Virtual WAN hub](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) associated with the virtual wan.
azurerm_virtual_hub_connection.vwan_01_hub_01_connections["vnet-shared-01"] | [Hub virtual network connection](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) to *azurerm_virtual_network.vnet_shared_01*.
azurerm_virtual_hub_connection.vwan_01_hub_01_connections["vnet-app-01"] | [Hub virtual network connection](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) to *azurerm_virtual_network.vnet_app_01*.

## Next steps

You have provisioned all of the configurations included in \#AzureSandbox. Now it's time to use your sandbox environment to experiment with additional Azure services and capabilities.
