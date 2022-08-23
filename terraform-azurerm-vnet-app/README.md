# \#AzureSandbox - terraform-azurerm-vnet-app

![vnet-app-diagram](./vnet-app-diagram.drawio.svg)

## Contents

* [Overview](#overview)
* [Before you start](#before-you-start)
* [Getting started](#getting-started)
* [Smoke testing](#smoke-testing)
* [Documentation](#documentation)
* [Next steps](#next-steps)

## Overview

This configuration implements a virtual network for applications including:

* A [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) for hosting for hosting [virtual machines](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) and private endpoints implemented using [PrivateLink](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview). [Virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) with [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared/) is automatically configured.
* A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) for use as a jumpbox.
* A Linux [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) for use as a jumpbox.
* An [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) database server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [SQL Server virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview#payasyougo) offering.
* A [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) database hosted in [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview) with a private endpoint implemented using [PrivateLink](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview).
* A [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) database hosted in [Azure Database for MySQL - Flexible Server](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/overview) with a private endpoint implemented using [subnet delegation](https://docs.microsoft.com/en-us/azure/virtual-network/subnet-delegation-overview).
* A [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) SMB file share hosted in [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) with a private endpoint implemented using [PrivateLink](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview).

Activity | Estimated time required
--- | ---
Pre-configuration | ~5 minutes
Provisioning | ~25 minutes
Smoke testing | ~ 30 minutes

## Before you start

The following configurations must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)

## Getting started

This section describes how to provision this configuration using default settings.

* Change the working directory.

  ```bash
  cd ~/azuresandbox/terraform-azurerm-vnet-app
  ```

* Add an environment variable containing the password for the service principal.

  ```bash
  export TF_VAR_arm_client_secret=YourServicePrincipalSecret
  ```

* Run [bootstrap.sh](./bootstrap.sh) using the default settings or custom settings.

  ```bash
  ./bootstrap.sh
  ```

* Apply the Terraform configuration.

  ```bash
  # Initialize terraform providers
  terraform init

  # Validate configuration files
  terraform validate

  # Review plan output
  terraform plan

  # Apply configuration
  terraform apply

  # List resources managed by terraform
  terraform state list 
  ```

## Smoke testing

The following sections provide guided smoke testing of each resource provisioned in this configuration, and should be completed in the order indicated.

* [Windows Server jumpbox VM smoke testing](#windows-server-jumpbox-vm-smoke-testing)
* [Azure Files smoke testing](#azure-files-smoke-testing)
* [SQL Server VM and Azure SQL Database smoke testing](#sql-server-vm-and-azure-sql-database-smoke-testing)
* [Azure Database for MySQL smoke testing](#azure-database-for-mysql-smoke-testing)

### Windows Server jumpbox VM smoke testing

* From the client environment, navigate to *portal.azure.com* > *Virtual machines* > *jumpwin1*
  * Click *Connect*, select the *Bastion* tab, then click *Use Bastion*
  * For *username* enter the UPN of the domain admin, which by default is *bootstrapadmin@mysandbox.local*.
  * For *password* use the value of the *adminpassword* secret in key vault.
  * Click *Connect*

* From *jumpwin1*, disable Server Manager
  * Navigate to *Server Manager* > *Manage* > *Server Manager Properties* and enable *Do not start Server Manager automatically at logon*
  * Close Server Manager

* From *jumpwin1*, Configure default browser
  * Navigate to *Settings* > *Apps* > *Default Apps* and set the default browser to *Microsoft Edge*.

* From *jumpwin1*, inspect the *mysandbox.local* Active Directory domain
  * Navigate to *Start* > *Windows Administrative Tools* > *Active Directory Users and Computers*.
  * Navigate to *mysandbox.local* and verify that a computer account exists in the root for the storage account, e.g. *stxxxxxxxxxxx*.
  * Navigate to *mysandbox.local* > *Computers* and verify that *jumpwin1*, *jumplinux1* and *mssqlwin1* are listed.
  * Navigate to *mysandbox.local* > *Domain Controllers* and verify that *adds1* is listed.

* From *jumpwin1*, inspect the *mysandbox.local* DNS zone
  * Navigate to *Start* > *Windows Administrative Tools* > *DNS*
  * Connect to the DNS Server on *adds1*.
  * Click on *adds1* in the left pane, then double-click on *Forwarders* in the right pane.
    * Verify that [168.63.129.16](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) is listed. This ensures that the DNS server will forward any DNS queries it cannot resolve to the Azure Recursive DNS resolver.
    * Click *Cancel*.
  * Navigate to *adds1* > *Forward Lookup Zones* > *mysandbox.local* and verify that there are *Host (A)* records for *adds1*, *jumpwin1*, *jumplinux1* and *mssqlwin1*.

* From *jumpwin1*, configure [Visual Studio Code](https://aka.ms/vscode) to do remote development on *jumplinux1*
  * Navigate to *Start* > *Visual Studio Code* > *Visual Studio Code*.
  * Install the [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension.
    * Navigate to *View* > *Extensions*
    * Search for *Remote-SSH*
    * Click *Install*
  * Configure SSH
    * Navigate to *View* > *Command Palette...* and enter:

      ```text
      Remote-SSH: Add New SSH Host
      ```

    * When prompted for *Enter SSH Connection Command* enter:

      ```text
      ssh bootstrapadmin@mysandbox.local@jumplinux1
      ```

    * When prompted for *Select SSH configuration file to update* choose *C:\\Users\\bootstrapadmin\\.ssh\\config*.

  * Connect to SSH host
    * Navigate to *View* >  *Command Palette...* and enter:

      ```text
      Remote-SSH: Connect to Host
      ```

    * Select *jumplinux1*
      * A second Visual Studio Code window will open.
    * When prompted for *Select the platform of the remote host "jumplinux1"* select *Linux*.
    * When prompted for *"jumplinux1" has fingerprint...* select *Continue*.
    * When prompted for *Enter password* use the value of the *adminpassword* secret in key vault.
      * This will install Visual Studio code remote development binaries on *jumplinux1*.
    * Verify that *SSH:jumplinux1* is displayed in the green status section in the lower left hand corner.
    * Connect to remote file system
      * Navigate to *View* > *Explorer*
      * Click *Open Folder*
      * Accept the default folder (home directory) and click *OK*.
      * When prompted for *Enter password* use the value of the *adminpassword* secret in key vault.
      * When prompted with *Do you trust the authors of the files in this folder?* click *Yes, I trust the authors*.
      * Review the home directory structure displayed in Explorer.
    * Open a bash terminal
      * Navigate to *View* > *Terminal*. This will open up a new bash shell.
      * Inspect the configuration of *jumplinux1* by executing the following commands from the bash command prompt:
  
        ```bash
        # Verify Linux distribution
        cat /etc/*-release

        # Verify Azure CLI version
        az --version

        # Verify PowerShell version
        pwsh --version

        # Verify Terraform version
        terraform --version
        ```

### Azure Files smoke testing

* Test DNS queries for Azure Files private endpoint
  * From the client environment, navigate to *portal.azure.com* > *Storage accounts* > *stxxxxxxxxxxx* > *File shares* > *myfileshare* > *Settings* > *Properties* and copy the the FQDN portion of the URL, e.g. *stxxxxxxxxxxx.file.core.windows.net*.
  * From *jumpwin1*, run the Windows PowerShell command:
  
    ```powershell
    Resolve-DnsName stxxxxxxxxxxx.file.core.windows.net
    ```

  * Verify the *IP4Address* returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-privatelink-01"]*, e.g. `10.2.2.*`.
  * Note: This DNS query is resolved using the following resources:
    * *azurerm_private_dns_a_record.storage_account_01_file*
    * *azurerm_private_dns_zone.private_dns_zones["privatelink.file.core.windows.net"]*
    * *azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_links_vnet_app_01["privatelink.file.core.windows.net"]*

* From *jumpwin1*, test SMB connectivity with integrated Windows Authentication to Azure Files private endpoint (PaaS)
  * Open a Windows command prompt and enter the following command:
  
    ```text
    net use z: \\stxxxxxxxxxxx.file.core.windows.net\myfileshare
    ```

  * Create some test files and folders on the newly mapped Z: drive
  * Note: Integrated Windows Authentication was configured using [configure-storage-kerberos.ps1](./configure-storage-kerberos.ps1) which was run by *azurerm_virtual_machine_extension.vm_jumpbox_win_postdeploy_script*.
  * Note: SMB connectivity with storage key authentication to Azure Files via the Internet will not be tested because most ISP's block port 445.

### SQL Server VM and Azure SQL Database smoke testing

* From *jumpwin1*, test DNS queries for SQL Server (IaaS)
  * Using Windows PowerShell, run the command:

    ```powershell
    Resolve-DnsName mssqlwin1
    ```

  * Verify the IPAddress returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-db-01"]*, e.g. `10.2.1.*`.
  * Note: This DNS query is resolved by the DNS Server running on *azurerm_windows_virtual_machine.vm_adds*.
* Test DNS queries for Azure SQL database private endpoint (PaaS)
  * From the client environment, navigate to *portal.azure.com* > *SQL Servers* > *mssql-xxxxxxxxxxxxxxxx* > *Overview* > *Server name* and and copy the the FQDN, e.g. *mssql&#x2011;xxxxxxxxxxxxxxxx.database.windows.net*.
  * From *jumpwin1*, run the Windows PowerShell command:
  
    ```powershell
    Resolve-DnsName mssql-xxxxxxxxxxxxxxxx.database.windows.net
    ```

  * Verify the *IP4Address* returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-privatelink-01"]*, e.g. `10.2.2.*`.
  * Note: This DNS query is resolved using the following resources:
    * *azurerm_private_dns_a_record.sql_server_01*
    * *azurerm_private_dns_zone.private_dns_zones["privatelink.database.windows.net"]*
    * *azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_links_vnet_app_01["privatelink.database.windows.net"]*

* From *jumpwin1*, test SQL Server Connectivity with SQL Server Management Studio (SSMS) (IaaS and PaaS)
  * Navigate to *Start* > *Microsoft SQL Server Tools 18* > *Microsoft SQL Server Management Studio 18*
  * Connect to the default instance of SQL Server installed on the database server virtual machine using the following default values:
    * Server name: *mssqlwin1*
    * Authentication: *Windows Authentication* (this will default to *MYSANDBOX\bootstrapadmin*)
    * Create a new database named *testdb*.
      * Verify the data files were stored on the *M:* drive
      * Verify the log file were stored on the *L:* drive
  * Connect to the Azure SQL Database server using PrivateLink
    * Server name: *mssql&#x2011;xxxxxxxxxxxxxxxx.database.windows.net*
    * Authentication: *SQL Server Authentication*
    * Login: *bootstrapadmin*
    * Password: Use the value stored in the *adminpassword* key vault secret
  * Expand the *Databases* tab and verify you can see *testdb*
* Optional: Deny internet access to Azure SQL Database
  * From the client environment, test DNS configuration
    * Verify that PrivateLink is not already configured on the private network
      * Open a Windows command prompt and run the following command:

        ```text
        ipconfig /all
        ```

      * Scan the results for *privatelink.database.windows.net* in *Connection-specific DNS Suffix Search List*.
        * If found, PrivateLink is already configured on the private network.
          * If you are directly connected to a private network, skip this portion of the smoke testing.
          * If you are connected to a private network using a VPN, disconnect from it and try again.
            * If the *privatelink.database.windows.net* DNS Suffix is no longer listed, you can continue.
    * Using Windows PowerShell, run this command and make a note of the *IP4Address* returned:

      ```powershell
      Resolve-DnsName mssql-xxxxxxxxxxxxxxxx.database.windows.net
      ```

    * Navigate to [lookip.net](https://www.lookip.net/ip) and lookup the *IP4Address* from the previous step. Examine the *Technical details* and verify that the ISP for the IP Address is *Microsoft Corporation* and the Company is *Microsoft Azure*.
  * Add Azure SQL Database firewall rule for client IP
    * From the client environment, navigate to *portal.azure.com* > *Home* > *SQL Servers* > *mssql&#x2011;xxxxxxxxxxxxxxxx* > *Security* > *Networking*
    * Confirm *Public network access* is set to *Selected networks*.
    * Navigate to *Firewall rules* and click *+ Add your client client IPV4 address...*.
    * Verify a firewall rule was added to match your client IP address.
      * Note: Only IPv4 addresses will work, so replace any IPv6 addresses with IPv4 addresses. Use [whatismyhipaddress.com](https://whatismyipaddress.com) to determine your IPv4 address.
    * Click *Save*
  * Test Internet connectivity to Azure SQL Database
    * Launch *Microsoft SQL Server Management Studio* (SSMS)
    * Connect to the Azure SQL Database server using public endpoint
      * Server name: *mssql&#x2011;xxxxxxxxxxxxxxxx.database.windows.net*
      * Authentication: *SQL Server Authentication*
      * Login: *bootstrapadmin*
      * Password: Use the value stored in the *adminpassword* key vault secret
    * Expand the *Databases* tab and verify you can see *testdb*
    * Disconnect from Azure SQL Database
  * Deny public network access
    * In Visual Studio code, navigate to line 14 of [060-mssql.tf](./060-mssql.tf)
    * Change `public_network_access_enabled` from `true` to `false` and save the changes.
    * In a bash terminal, run the following commands to apply changes to the configuration:

      ```bash
      # Verify plan will change one property on one resource only
      terraform plan

      # Apply the change
      terraform apply
      ```
  
  * Test Internet connectivity to Azure SQL Database
    * Launch *Microsoft SQL Server Management Studio* (SSMS)
    * Connect to the Azure SQL Database server using public endpoint
      * Server name: *mssql&#x2011;xxxxxxxxxxxxxxxx.database.windows.net*
      * Authentication: *SQL Server Authentication*
      * Login: *bootstrapadmin*
      * Password: Use the value stored in the *adminpassword* key vault secret
    * Verify the connection was denied and examine the error message

### Azure Database for MySQL smoke testing

* Test DNS queries for Azure Database for MySQL private endpoint (PaaS)
  * From the client environment, navigate to *portal.azure.com* > *Azure Database for MySQL flexible servers* > *mysql-xxxxxxxxxxxxxxxx* > *Overview* > *Server name* and and copy the the FQDN, e.g. *mysql&#x2011;xxxxxxxxxxxxxxxx.mysql.database.azure.com*.
  * From *jumpwin1*, run the following Windows PowerShell command:
  
    ```powershell
    Resolve-DnsName mysql-xxxxxxxxxxxxxxxx.mysql.database.azure.com
    ```

  * Verify the *IP4Address* returned is within the subnet IP address prefix for *azurerm_subnet.vnet_app_01_subnets["snet-mysql-01"]*, e.g. `10.2.3.*`.
  * Note: This DNS query is resolved using the following resources:
    * A DNS A record is added for the MySQL server automatically by the provisioning process. This can be verified in the Azure portal by navigating to *Private DNS zones* > *private.mysql.database.azure.com* and viewing the A record listed.
    * *azurerm_private_dns_zone.private_dns_zones["private.mysql.database.azure.com"]*
    * *azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_links_vnet_app_01["private.mysql.database.azure.com"]*

* From *jumpwin1*, test private MySQL connectivity using MySQL Workbench.
  * Navigate to *Start* > *MySQL Workbench*
  * Navigate to *Databawse* > *Connect to Database* and connect using the following values:
    * Connection method: Standard (TCP/IP)
    * Hostname: mssql-xxxxxxxxxxxxxxxx.mysql.database.azure.com
    * Port: 3306
    * Uwername: bootstrapadmin
    * Schema: testdb
    * Click *OK* and when prompted for *password* use the value of the *adminpassword* secret in key vault.
    * Create a table, insert some data and run some sample queries to verify functionality.

## Documentation

This section provides additional information on various aspects of this configuration.

### Bootstrap script

This configuration uses the script [bootstrap.sh](./bootstrap.sh) to create a *terraform.tfvars* file for generating and applying Terraform plans. For simplified deployment, several runtime defaults are initialized using output variables stored in the *terraform.tfstate* file associated with the [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared) configuration, including:

Output variable | Sample value
--- | ---
aad_tenant_id | "00000000-0000-0000-0000-000000000000"
adds_domain_name | "mysandbox.local"
admin_password_secret | "adminpassword"
admin_username_secret | "adminuser"
arm_client_id | "00000000-0000-0000-0000-000000000000"
automation_account_name | "auto-9a633c2bba9351cc-01"
dns_server | "10.1.1.4"
key_vault_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sandbox-01/providers/Microsoft.KeyVault/vaults/kv-XXXXXXXXXXXXXXX"
key_vault_name | "kv-XXXXXXXXXXXXXXX"
location | "eastus"
resource_group_name | "rg-sandbox-01"
storage_account_name | "stXXXXXXXXXXXXXXX"
storage_container_name | "scripts"
subscription_id | "00000000-0000-0000-0000-000000000000"
tags | tomap( { "costcenter" = "10177772" "environment" = "dev" "project" = "#AzureSandbox" } )
vnet_shared_01_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sandbox-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01"
vnet_shared_01_name | "vnet-shared-01"

The following PowerShell scripts are uploaded to the *scripts* container in the storage account using the access key stored in the key vault secret *storage_account_key* so they can be referenced by virtual machine extensions:

* [configure-storage-kerberos.ps1](./configure-storage-kerberos.ps1)
* [configure-vm-jumpbox-win.ps1](./configure-vm-jumpbox-win.ps1)
* [configure-vm-mssql.ps1](./configure-vm-mssql.ps1)
* [sql-startup.ps1](./sql-startup.ps1)

Configuration of [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview) is performed by [configure-automation.ps1](./configure-automation.ps1) including the following:

* Configures [Azure Automation shared resources](https://docs.microsoft.com/en-us/azure/automation/automation-intro#shared-resources) including:
  * [Modules](https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules)
    * Imports new modules including the following:
      * [NetworkingDsc](https://github.com/dsccommunity/NetworkingDsc)
      * [SqlServerDsc](https://github.com/dsccommunity/SqlServerDsc)
      * [cChoco](https://github.com/chocolatey/cChoco)
  * Imports [DSC Configurations](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-getting-started#create-a-dsc-configuration) used in this configuration.
    * [JumpBoxConfig.ps1](./JumpBoxConfig.ps1): domain joins a Windows Server virtual machine and adds it to a `JumpBoxes` security group, then and configures it as jumpbox.
    * [MssqlVmConfig.ps1](./MssqlVmConfig.ps1): domain joins a Windows Server virtual machine and adds it to a `DatabaseServers` security group, then configures it as a database server.
  * [Compiles DSC Configurations](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-compile) so they can be used later to [Register a VM to be managed by State Configuration](https://docs.microsoft.com/en-us/azure/automation/tutorial-configure-servers-desired-state#register-a-vm-to-be-managed-by-state-configuration).

### Terraform Resources

This section lists the resources included in this configuration.

#### Network resources

The configuration for these resources can be found in [020-network.tf](./020-network.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_virtual_network . vnet_app_01 (vnet&#x2011;app&#x2011;01) | By default this virtual network is configured with an address space of `10.2.0.0/16` and is configured with DNS server addresses of 10.1.2.4 (the private ip for *azurerm_windows_virtual_machine.vm_adds*) and [168.63.129.16](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16).
azurerm_subnet . vnet_app_01_subnets ["snet-app-01"] | The default address prefix for this subnet is `10.2.0.0/24` and is reserved for web, application and jumpbox servers. A network security group is associated with this subnet that permits ingress and egress from virtual networks, and egress to the Internet.
azurerm_subnet . vnet_app_01_subnets ["snet-db-01"] | The default address prefix for this subnet is `10.2.1.0/24` which includes the private ip address for *azurerm_windows_virtual_machine.vm_mssql_win*. A network security group is associated with this subnet that permits ingress and egress from virtual networks, and egress to the Internet.
azurerm_subnet .vnet_app_01_subnets ["snet-privatelink-01"] | The default address prefix for this subnet is `10.2.2.0/24`. *private_endpoint_network_policies_enabled* is enabled for use with [PrivateLink](https://docs.microsoft.com/en-us/azure/private-link/private-link-overview). A network security group is associated with this subnet that permits ingress and egress from virtual networks.
azurerm_subnet . vnet_app_01_subnets ["snet-mysql-01"] | The default address prefix for this subnet is `10.2.3.0/24`. *service_delegation_name* is set to `Microsoft.DBforMySQL/flexibleServers` for use with [subnet delegation](https://docs.microsoft.com/en-us/azure/virtual-network/subnet-delegation-overview). A network security group is associated with this subnet that permits ingress and egress from virtual networks.
azurerm_virtual_network_peering . vnet_shared_01_to_vnet_app_01_peering | Establishes the [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) relationship from *azurerm_virtual_network.vnet_shared_01* to *azurerm_virtual_network.vnet_app_01*.
azurerm_virtual_network_peering . vnet_app_01_to_vnet_shared_01_peering | Establishes the [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) relationship from *azurerm_virtual_network.vnet_app_01* to *azurerm_virtual_network.vnet_shared_01*.
azurerm_private_dns_zone . private_dns_zones ["private.mysql.database.azure.com"] | Creates a [private Azure DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) for using [Private Network Access for Azure Database for MySQL - Flexible Server](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking-vnet).
azurerm_private_dns_zone . private_dns_zones ["privatelink.database.windows.net"] | Creates a [private Azure DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) for using [Azure Private Link for Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview).
azurerm_private_dns_zone . private_dns_zones ["privatelink.file.core.windows.net"] | Creates a [private Azure DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) for using [Azure Private Link for Azure Files](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints).
azurerm_private_dns_zone_virtual_network_link . private_dns_zone_virtual_network_links_vnet_app_01 [*] | Links each of the private DNS zones with azurerm_virtual_network.vnet_app_01
azurerm_private_dns_zone_virtual_network_link . private_dns_zone_virtual_network_links_vnet_shared_01 [*] | Links each of the private DNS zones with *var.remote_virtual_network_id*, which is the shared services virtual network.

#### Windows Server Jumpbox VM

The configuration for these resources can be found in [030-vm-jumpbox-win.tf](./030-vm-jumpbox-win.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_windows_virtual_machine.vm_jumpbox_win (jumpwin1) | By default, provisions a [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) virtual machine for use as a jumpbox. See below for more information.
azurerm_network_interface.vm_jumpbox_win_nic_01 (nic&#x2011;jumpwin1&#x2011;1) | The configured subnet is *azurerm_subnet.vnet_app_01_subnets["snet-app-01"]*.
azurerm_virtual_machine_extension.vm_jumpbox_win_postdeploy_script | Downloads [configure&#x2011;vm&#x2011;jumpbox-win.ps1](./configure-vm-jumpbox-win.ps1) and [configure&#x2011;storage&#x2011;kerberos.ps1](./configure-storage-kerberos.ps1), then executes [configure&#x2011;vm&#x2011;jumpbox-win.ps1](./configure-vm-jumpbox-win.ps1) using the [Custom Script Extension for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows). See below for more details.

This Windows Server VM is used as a jumpbox for development and remote server administration.

* Guest OS: Windows Server 2019 Datacenter.
* By default the [patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByPlatform`.
* *admin_username* and *admin_password* are configured using the key vault secrets *adminuser* and *adminpassword*.
* This resource is configured using a [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) that runs [aadsc-register-node.ps1](./aadsc-register-node.ps1) which registers the node with *azurerm_automation_account.automation_account_01* and applies the configuration [JumpBoxConfig](./JumpBoxConfig.ps1).
  * The virtual machine is domain joined  and added to `JumpBoxes` security group.
  * The following [Remote Server Administration Tools (RSAT)](https://docs.microsoft.com/en-us/windows-server/remote/remote-server-administration-tools) are installed:
    * Active Directory module for Windows PowerShell (RSAT-AD-PowerShell)
    * Active Directory Administrative Center (RSAT-AD-AdminCenter)
    * AD DS Snap-Ins and Command-Line Tools (RSAT-ADDS-Tools)
    * DNS Server Tools (RSAT-DNS-Server)
  * The following software packages are pre-installed using [Chocolatey](https://chocolatey.org/why-chocolatey):
    * [microsoft-edge](https://community.chocolatey.org/packages/microsoft-edge)
    * [az.powershell](https://community.chocolatey.org/packages/az.powershell)
    * [vscode](https://community.chocolatey.org/packages/vscode)
    * [sql-server-management-studio](https://community.chocolatey.org/packages/sql-server-management-studio)
    * [microsoftazurestorageexplorer](https://community.chocolatey.org/packages/microsoftazurestorageexplorer)
    * [azcopy10](https://community.chocolatey.org/packages/azcopy10)
    * [azure-data-studio](https://community.chocolatey.org/packages/azure-data-studio)
    * [mysql.workbench](https://community.chocolatey.org/packages/mysql.workbench)
* Post-deployment configuration is then performed using a custom script extension that runs [configure&#x2011;vm&#x2011;jumpbox&#x2011;win.ps1](./configure-vm-jumpbox-win.ps1).
  * [configure&#x2011;storage&#x2011;kerberos.ps1](./configure-storage-kerberos.ps1) is registered as a scheduled task then executed using domain administrator credentials. This script must be run on a domain joined Azure virtual machine, and configures the storage account for kerberos authentication with the Active Directory Domain Services domain used in the configurations.

#### Linux Jumpbox VM

The configuration for these resources can be found in [040-vm-jumpbox-linux.tf](./040-vm-jumpbox-linux.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_linux_virtual_machine.vm_jumpbox_linux (jumplinux1) | By default, provisions a [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) virtual machine for use as a Linux jumpbox virtual machine. See below for more details.
azurerm_network_interface.vm_jumbox_linux_nic_01 | The configured subnet is *azurerm_subnet.vnet_app_01_subnets["snet-app-01"]*.
azurerm_key_vault_access_policy.vm_jumpbox_linux_secrets_get | Allows the VM to get secrets from key vault using a system assigned managed identity.

This Linux VM is used as a jumpbox for development and remote administration.

* Guest OS: Ubuntu 20.04 LTS (Focal Fossa)
* By default the [patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByPlatform`.
* A system assigned [managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) is configured by default for use in DevOps related identity and access management scenarios.
* Custom tags are added which are used by [cloud-init](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init#:~:text=%20There%20are%20two%20stages%20to%20making%20cloud-init,is%20already%20configured%20to%20use%20cloud-init.%20More%20) [User-Data Scripts](https://cloudinit.readthedocs.io/en/latest/topics/format.html#user-data-script) to configure the virtual machine.
  * *keyvault*: Used in cloud-init scripts to determine which key vault to use for secrets.
  * *adds_domain_name*: Used in cloud-init scripts to join the domain.
* This VM is configured with [cloud-init](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init#:~:text=%20There%20are%20two%20stages%20to%20making%20cloud-init,is%20already%20configured%20to%20use%20cloud-init.%20More%20) using a [Mime Multi Part Archive](https://cloudinit.readthedocs.io/en/latest/topics/format.html#mime-multi-part-archive) containing the following files:
  * [configure-vm-jumpbox-linux.yaml](./configure-vm-jumpbox-linux.yaml) is [Cloud Config Data](https://cloudinit.readthedocs.io/en/latest/topics/format.html#cloud-config-data) used to configure the VM.
    * The following packages are installed:
      * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest)
      * [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1)
      * [Terraform](https://www.terraform.io/intro/index.html#what-is-terraform-)
      * [jp](https://packages.ubuntu.com/focal/jp)
      * [Kerberos](https://kerberos.org/software/mixenvkerberos.pdf) packages required to AD domain join a Linux host and enable dynamic DNS (DDNS) registration.
        * [krb5-user](https://packages.ubuntu.com/focal/krb5-user)
        * [samba](https://packages.ubuntu.com/focal/samba)
        * [sssd](https://packages.ubuntu.com/focal/sssd)
        * [sssd-tools](https://packages.ubuntu.com/focal/sssd-tools)
        * [libnss-sss](https://packages.ubuntu.com/focal/libnss-sss)
        * [libpam-sss](https://packages.ubuntu.com/focal/libpam-sss)
        * [ntp](https://packages.ubuntu.com/focal/ntp)
        * [ntpdate](https://packages.ubuntu.com/focal/ntpdate)
        * [realmd](https://packages.ubuntu.com/focal/realmd)
        * [adcli](https://packages.ubuntu.com/focal/adcli)
    * Package update and upgrades are performed.
    * The VM is rebooted if necessary.
  * [configure-vm-jumpbox-linux.sh](./configure-vm-jumpbox-linux.sh) is a [User-Data Script](https://cloudinit.readthedocs.io/en/latest/topics/format.html#user-data-script) used to configure the VM.
    * Runtime values are retrieved using [Instance Metadata](https://cloudinit.readthedocs.io/en/latest/topics/instancedata.html#instance-metadata)
      * The name of the key vault used for secrets is retrieved from the tag named *keyvault*.
      * The Active Directory domain name is retrieved from the tag named *adds_domain_name*.
      * An access token is generated using the VM's system assigned managed identity.
      * The access token is used to get secrets from key vault, including:
        * *adminuser*: The name of the administrative user account for configuring the VM (e.g. "bootstrapadmin" by default).
        * *adminpassword*: The password for the administrative user account.
      * The networking configuration of the VM is modified to enable domain joining the VM
        * The *hosts* file is updated to reference the newly configured host name and domain name.
        * The DHCP client configuration file *dhclient.conf* is updated to include the newly configured domain name.
      * The VM is domain joined
        * The *ntp.conf* file is updated to synchronize the time with the domain controller.
        * The *krb5.conf* file is updated to disable the *rdns* setting.
        * *dhclient* is run to refresh the DHCP settings using the new networking configuration.
        * *realm join* is run to join the domain
      * The VM is registered with the DNS server
        * A local *keytab* file is created and used to authenticate with the domain using *kinit*
        * A new A record is added to the DNS server using *nsupdate*.
      * Dynamic DNS registration is configured
        * A new DHCP client exit hook script named `/etc/dhcp/dhclient-exit-hooks.d/hook-ddns` is created which runs whenever the DHCP client exits.
          * The script uses *kinit* to authenticate with the domain using the previously created keytab file.
          * The old A record is deleted and a new A record is added to the DNS server using *nsupdate*.
      * Privileged access management is configured.
        * Automatic home directory creation is enabled.
        * The domain administrator account is configured.
          * Logins are permitted.
          * Sudo privileges are granted.
      * SSH server is configured for logins using Active Directory accounts.

#### Database server virtual machine

The configuration for these resources can be found in [050-vm-mssql-win.tf](./050-vm-mssql-win.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_windows_virtual_machine . vm_mssql_win (mssqlwin1) | By default, provisions a [Standard_B4ms](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) virtual machine for use as a database server. See below for more information.
azurerm_network_interface . vm_mssql_win_nic_01 (nic&#x2011;mssqlwin1&#x2011;1) | The configured subnet is *azurerm_subnet.vnet_app_01_subnets["snet-db-01"]*.
azurerm_managed_disk . vm_mssql_win_data_disks ["sqldata"] (disk&#x2011;mssqlwin1&#x2011;vol_sqldata_M) | By default, provisions an E10 [Standard SSD](https://docs.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssd) [managed disk](https://docs.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview) for storing SQL Server data files. Caching is set to *ReadOnly* by default.
azurerm_managed_disk . vm_mssql_win_data_disks ["sqllog"] (disk&#x2011;mssqlwin1&#x2011;vol_sqllog_L) | By default, provisions an E4 [Standard SSD](https://docs.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssd) [managed disk](https://docs.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview) for storing SQL Server log files. Caching is set to *None* by default.
azurerm_virtual_machine_data_disk_attachment . vm_mssql_win_data_disk_attachments ["sqldata"] | Attaches *azurerm_managed_disk.vm_mssql_win_data_disks["sqldata"]* to *azurerm_windows_virtual_machine.vm_mssql_win*.
azurerm_virtual_machine_data_disk_attachment . vm_mssql_win_data_disk_attachments ["sqllog"] | Attaches *azurerm_managed_disk.vm_mssql_win_data_disks["sqllog"]* to *azurerm_windows_virtual_machine.vm_mssql_win*
azurerm_virtual_machine_extension . vm_mssql_win_postdeploy_script (vmext&#x2011;mssqlwin1&#x2011;postdeploy&#x2011;script) | Downloads [configure&#x2011;vm&#x2011;mssql.ps1](./configure-mssql.ps1) and [sql&#x2011;startup.ps1](./sql-startup.ps1) to *azurerm_windows_virtual_machine.vm_mssql_win* and executes [configure&#x2011;vm&#x2011;mssql.ps1](./configure-mssql.ps1) using the [Custom Script Extension for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows).

* Guest OS: Windows Server 2019 Datacenter.
* By default the [patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByOS` rather than `AutomaticByPlatform`. This is intentional in case the user wishes to use the [SQL Server IaaS Agent extension](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-iaas-agent-extension-automate-management?tabs=azure-powershell) for patching both Windows Server and SQL Server.
* *admin_username* and *admin_password* are configured using key vault secrets *adminuser* and *adminpassword*.
* This resource is configured using a [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) that runs [aadsc-register-node.ps1](./aadsc-register-node.ps1) which registers the node with *azurerm_automation_account.automation_account_01* and applies the configuration [MssqlVmConfig.ps1](../terraform-azurerm-vnet-shared/MssqlVmConfig.ps1).
  * The default SQL Server instance is configured to support [mixed mode authentication](https://docs.microsoft.com/en-us/sql/relational-databases/security/choose-an-authentication-mode). This is to facilitate post-installation configuration of the default instance before the virtual machine is domain joined, and can be reconfigured to Windows authentication mode if required.
    * The builtin *sa* account is enabled and the password is configured using *adminpassword* key vault secret.
    * The *LoginMode* registry key is modified to support mixed mode authentication.
  * The virtual machine is domain joined.
  * The [Windows Firewall](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/windows-firewall-with-advanced-security#overview-of-windows-defender-firewall-with-advanced-security) is [Configured to Allow SQL Server Access](https://docs.microsoft.com/en-us/sql/sql-server/install/configure-the-windows-firewall-to-allow-sql-server-access). A new firewall rule is created that allows inbound traffic over port 1433.
  * A SQL Server Windows login is added for the domain administrator and added to the SQL Server builtin `sysadmin` role.
* Post-deployment configuration is then implemented using a custom script extension that runs [configure-mssql.ps1](./configure-mssql.ps1) following guidelines established in [Checklist: Best practices for SQL Server on Azure VMs](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist).
  * Data disk metadata is retrieved dynamically using the [Azure Instance Metadata Service (Windows)](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service?tabs=windows) including:
    * Volume label and drive letter, e.g. *vol_sqldata_M*
    * Size
    * Lun
  * The metadata is then used to partition and format the raw data disks using the SQL Server recommended allocation unit size of 64K.
  * The *tempdb* database is moved from the OS disk to the Azure local temporary disk (D:) and special logic is implemented to avoid errors if the Azure virtual machine is stopped, deallocated and restarted on a different host. If this occurs the `D:\SQLTEMP` folder must be recreated with appropriate permissions in order to start the SQL Server.
    * The SQL Server is configured for manual startup
    * The scheduled task [sql-startup.ps1](./sql-startup.ps1) is created to recreate the `D:\SQLTEMP` folder then start SQL Server. The scheduled task is set to run automatically at startup using domain administrator credentials.
  * The data and log files for the *master*, *model* and *msdb* system databases are moved to the data and log disks respectively.
  * The SQL Server errorlog is moved to the data disk.
  * SQL Server `max server memory` is reconfigured to use 90% of available memory.
  
#### Azure SQL Database

The configuration for these resources can be found in [060-mssql.tf](./060-mssql.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_mssql_server.mssql_server_01 (mssql-xxxxxxxxxxxxxxxx) | An [Azure SQL Database logical server](https://docs.microsoft.com/en-us/azure/azure-sql/database/logical-servers) for hosting databases.
azurerm_mssql_database.mssql_database_01 | A [single database](https://docs.microsoft.com/en-us/azure/azure-sql/database/single-database-overview) named *testdb* for testing connectivity.
azurerm_private_endpoint.mssql_server_01 | A private endpoint for connecting to [Azure SQL Database using PrivateLink](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview)
azurerm_private_dns_a_record.sql_server_01 | A DNS A record for resolving DNS queries to *azurerm_mssql_server.mssql_server_01* using PrivateLink. This resource has a dependency on the *azurerm_private_dns_zone.database_windows_net* resource.

#### Azure Database for MySQL Flexible Server

The configuration for these resources can be found in [080-mysql.tf](./080-mysql.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_mysql_flexible_server.mysql_server_01 (mysql-xxxxxxxxxxxxxxxx) | An [Azure Database for MySQL - Flexible Server](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/overview) for hosting databases. Note that a private endpoint is automatically created during provisioning and a corresponding DNS A record is automatically added to the corresponding private DNS zone.
azurerm_mysql_flexible_database.mysql_database_01 | A MySQL Database named *testdb* for testing connectivity.

#### Storage resources

The configuration for these resources can be found in [070-storage-share.tf](./070-storage-share.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_storage_share.storage_share_01 | An [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) SMB file share. See below for more information.
azurerm_private_endpoint.storage_account_01_file | A private endpoint for connecting to file service endpoint of the shared storage account.
azurerm_private_dns_a_record.storage_account_01_file | A DNS A record for resolving DNS queries to *azurerm_storage_share.storage_share_01* using PrivateLink. This resource has a dependency on the *azurerm_private_dns_zone.file_core_windows_net* resource.

* Hosted by the storage account created by [terraform-azurerm-vnet-shared/bootstrap.sh](../terraform-azurerm-vnet-shared/README.md#bootstrap-script).
* Connectivity using private endpoints is enabled. See [Use private endpoints for Azure Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints) for more information.
* Kerberos authentication is configured with the sandbox domain using a post-deployment script executed on *azurerm_windows_virtual_machine.vm_jumpbox_win*.

### Terraform output variables

This section lists the output variables defined in the Terraform configurations in this configuration. Some of these may be used for automation in other configurations.

Output variable | Sample value
--- | ---
vnet_app_01_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sandbox-01/providers/Microsoft.Network/virtualNetworks/vnet-app-01"
vnet_app_01_name | "vnet-app-01"

## Next steps

Move on to the next configuration [terraform-azurerm-vwan](../terraform-azurerm-vwan).
