# Azure sample configuration: terraform-azurerm-vwan  

## Overview

This sample implements a shared virtual wan to connect the shared services virtual network and the dedicated spoke virtual network to remote users and/or private networks. The following samples must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
  * [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)
  * [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
  * [terraform-azurerm-sql](../terraform-azurerm-sql)

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~30 minutes
Smoke testing | ~45 minutes
De-provisioning | ~30 minutes

## Getting started

This section describes how to provision this sample using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 6 resources included in this sample.

### Virtual wan

---

Shared [virtual wan](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) to connect the shared services and dedicated spoke virtual networks to remote users and/or private networks with an automatically generated name following the grep format "vwan-\[a-z0-9\]\{16\}-01". The following arguments are configured by default:

* [disable_vpn_encryption](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#disable_vpn_encryption) = false
* [allow_branch_to_branch_traffic](https://www.terraform.io/docs/providers/azurerm/r/virtual_wan.html#allow_branch_to_branch_traffic) = true

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vwan_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualWans/vwan-e2b88962e7284da0-01
vwan_01_name | Output | string | Local | vwan-e2b88962e7284da0-01

#### Virtual WAN Hub

Shared [virtual WAN hub](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) attached to the shared virtual wan with an automatically generated name following the grep format "vhub-\[a-z0-9\]\{16\}-01". Pre-configured [hub virtual network connections](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) are established with the shared services virtual network and the dedicated spoke virtual network.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vwan_hub_address_prefix | Input | string | Local | 10.3.0.0/16
vwan_01_hub_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualHubs/vhub-6c8fe94d3b690bf9-01
vwan_01_hub_01_name | Output | string | Local | vhub-6c8fe94d3b690bf9-01

## Smoke testing

These smoke tests are designed to be performed from a Windows 10 client over a P2S VPN connection to the Azure Virtual WAN Hub. Upon completion you will have tested connectivity using a variety of ports and protocols to Azure resources using private IP addresses.

### Test Point to Site (P2S) VPN Connectivity

This smoke test establishes a Point to Site (P2S) VPN connection to the Virtual Wan Hub using the [Azure VPN Client](https://www.microsoft.com/store/productId/9NP355QT2SQB) as described in [Tutorial: Create a User VPN connection using Azure Virtual WAN](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-point-to-site-portal), then tests that connectivity by establishing a drive mapping to the the Azure Files private endpoint established in [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared).

* Generate self-signed certificates to use for P2S VPN certificate authentication.
  * Using the Windows 10 client you intend to test connectivity with, generate the certificates required for setting up P2S VPN using `genp2svpncerts.ps1`. This script creates a root certificate in the registry, then uses that root certificate to create a self-signed client certificate in the registry. Both certificates are then exported to files:
    * `MyP2SVPNRootCert_DER_Encoded.cer`: This is a temporary file used to create a Base64 encoded version of the root certificate.
    * `MyP2SVPNRootCert_Base64_Encoded.cer`: This is the root certificate used to create a User VPN Configuration in Virtual WAN.
    * `MyP2SVPNChildCert.pfx`: This is an export of the client certificate protected with a password. You only need this if you want to configure the Azure VPN client on a different computer than the one used to generate the certificates.
  * Make a note of the CN for the root certificate, the default is `MyP2SVPNRootCert`.
* Create a User VPN Configuration as described in [Create a P2S configuration](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-point-to-site-portal#p2sconfig).
  * Configuration name: `UserVPNConfig1`
  * Tunnel type: `OpenVPN`
  * Authentication method: `Azure certificate`
  * ROOT CERTIFICATE NAME: `MyP2SVPNRootCert` (default)
  * PUBLIC CERTIFICATE DATA: Paste in the content of `MyP2SVPNRootCert_Base64_Encoded.cer`, not including the begin / end certificate lines.
* Create User (P2S) VPN Gateway. This can take rougly 15 minutes.
  * In the Azure Portal, navigate to *Home > Virtual WANs > vwan-XXXX-01 > Hubs > vhub-XXXX-01 > User VPN (Point to site)*
  * Gateway scale units: `1 scale unit - 1 Gbps`
  * Point to site configuration: `UserVPNConfig1`
  * Client address pool: `10.4.0.0/16`
  * Custom DNS servers: `168.63.129.16` (See [What is IP address 168.63.129.16?](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) for more info)
* Download Virtual Hub User VPN Profile
  * In the Azure Portal, navigate to *Home > Virtual WANs > vwan-XXXX-01 > Hubs > vhub-XXXX-01 > User VPN (Point to site)*
  * Click *Download virtual Hub User VPN profile*
    * Authentication type: *EAPTLS*
    * Click *Generate and download profile*
    * Extract the files from the archive and examine `AzureVPN\azurevpnconfig.xml`.
* Install and configure VPN Client
  * Install the [Azure VPN Client](https://www.microsoft.com/store/productId/9NP355QT2SQB).
  * Launch the Azure VPN Client
  * Click *+ + Add or import a new VPN connection* in the lower left corner of the window
  * Click *Import*
  * Navigate to the `AzureVPN` folder from the previous step, and open `azurevpnconfig.xml`.
    * Client authentication
      * Authentication Type: *Certificate*
      * Certificate Information: `MyP2SVPNChildCert` (Note: If you do not see this certificate you need to import the .pfx created in a previous step)
  * Click *Save*
  * Connect and inspect routes. If you went with the default sample configuration you should see these address ranges:
    * `10.1.0.0/16`: Shared services Virtual Network
    * `10.2.0.0/16`: Spoke Virtual Network
    * `10.3.0.0/16`: Virtual WAN Hub
    * `10.4.0.0/17`: P2S client VPN connections
    * `10.4.128.0/17`: P2S client VPN connections
    * `10.4.0.2`: VPN IP Address (this client)
  * Test RDP (port 3389) connectivity using private IP address (not bastion)
    * Find the private IP address for the *Windows jump box virtual machine* in [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows).
    * Launch *Remote Desktop Connection* (`mstsc.exe`) and verify you can connect using the private IP address and bootstrap credentials.
  * Test SSH (port 22) connectivity using private IP address (not bastion)
    * Install [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/)
    * Find the private IP address for the *Linux jump box virtual machine* in [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux).
    * Launch *PuTTY* (`mstsc.exe`) and verify you can connect using the private IP address and bootstrap credentials.
  * Test SMB (port 445) connectivity to private IP address
    * Manually configure DNS name resolution for File Share that was provisioned in [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
      * Run `terraform output` in `terraform-azurerm-vnet-shared` and make a note of the the following values:
        * `storage_account_01_private_endpoint_file_prvip`, e.g. `10.1.2.4`
        * `storage_share_01_url`, e.g. `https://st2fb53ab20772e9a501.file.core.windows.net/fs-95d43e7000c51409-01`. Make a note of the fqdn, e.g. `st2fb53ab20772e9a501.file.core.windows.net`
      * Update the local `hosts` file for your Windows 10 client
        * Run notepad as Administrator and open `C:\Windows\System32\drivers\etc\hosts`
        * Add a line to the end which resolves the fqdn for the File Share to the private ip, e.g. `10.1.2.4 st2fb53ab20772e9a501.file.core.windows.net`
        * Save the updated `hosts` file
      * Test that name resolution to the private ip is working using Powershell, e.g. `Resolve-DnsName st2fb53ab20772e9a501.file.core.windows.net`.
    * Map a drive using the File Share private endpoint
      * In the Azure Portal, navigate to the storage account provisioned in [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared), e.g. `st2fb53ab20772e9a501`
      * Navigate to *File Shares* and click on the File Share provisioned in [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared), e.g. `fs-95d43e7000c51409-01`
      * Click *Connect* and copy the PowerShell script displayed in the text box.
      * Paste the script into a new script window in PowerShell ISE and save it, then execute the script.
    * Copy some files to the newly mapped drive.
  * Test SQL Server / TDS (port 1433) connectivity to private IP address
    * Install [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15)
    * Manually configure DNS name resolution for SQL Database that was provisioned in [terraform-azurerm-sql](../terraform-azurerm-sql)
      * Run `terraform output` in `terraform-azurerm-sql` and make a note of the the following values:
        * `sql_server_01_private_endpoint_prvip`, e.g. `10.2.1.100`.
        * `sql_server_01_fqdn`, e.g. `sql-ddf012de2c97ae5b-01.database.windows.net`.
      * Update the local `hosts` file for your Windows 10 client
        * Run notepad as Administrator and open `C:\Windows\System32\drivers\etc\hosts`
        * Add a line to the end which resolves the fqdn for the File Share to the private ip, e.g. `10.2.1.100 sql-ddf012de2c97ae5b-01.database.windows.net`
        * Save the updated `hosts` file
      * Test that name resolution to the private ip is working using Powershell, e.g. `Resolve-DnsName sql-ddf012de2c97ae5b-01.database.windows.net`.
    * Connect to SQL Database using SQL Server Management Studio
      * Launch SQL Server Management Studio
      * Connect using SQL Server Authentication
        * Server name: The fqdn of the SQL Database used earlier, e.g. `sql-ddf012de2c97ae5b-01.database.windows.net`.
        * Login: Use the bootstrap credentials from [terraform-azurerm-sql](../terraform-azurerm-sql), e.g. `bootstrapadmin`
    * Create a test database and enter some test data.

## Next steps

Connect the shared virtual wan hub to private networks using [site-to-site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices) (S2S) or [ExpressRoute](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-introduction).
