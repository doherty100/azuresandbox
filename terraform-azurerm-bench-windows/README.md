# Azure quick start configuration: terraform-azurerm-bench-windows  

## Overview

This quick start implements a collection of services for testing Windows based web applications and running database benchmarks like [HammerDB](https://www.hammerdb.com/) using an [IaaS](https://azure.microsoft.com/en-us/overview/what-is-azure/iaas/) approach. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
* [terraform-azurerm-vm-windows](../terraofrm-azurerm-vm-windows)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~15 minutes
De-provisioning | ~5 minutes

### Getting started with default settings

This section describes how to provision this quick start using default settings.

* Create required secrets in shared key vault and provision post-deployment script
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Note that the password must be at least 12 characters long and meet [defined complexity requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm). Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `./run-gen-tfvarsfile.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

### Getting started with custom settings

This section describes how to provision this quick start using custom settings. Refer to [Perform custom quick start deployment](https://github.com/doherty100/azurequickstarts#perform-custom-quick-start-deployment) for more details.

* Create required secrets in shared key vault and provision post-deployment script
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Note that the password must be at least 12 characters long and meet [defined complexity requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm). Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh`.
  * -n: Change to a custom *vm_name* if desired.
  * -s: Change to a different *vm_image_sku* if desired.
    * Run `az vm image list-skus -l eastus -p MicrosoftSQLServer -f sql2019-ws2019 -o table` for a list of valid image sku names. Change the -l parameter to the desired location.
  * -z: Change to a different *vm_size* if desired.
    * Run `az vm list-sizes -l eastus -o table` for a list of sizes. Change the -l parameter to the desired location.
  * -c: Change to a different *vm_data_disk_count* if desired. Set to "0" of no data disks are required.
  * -d: Change to a different *vm_data_disk_size_gb* if desired.
  * -t: Change to a different *tags* map if desired.
  * Save changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

## Resource index

This section provides an index of the ~7 resources included in this quick start.

### Database server virtual machine

---

Database Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [SQL Server on Azure Virtual Machine \(Windows\)](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview) offering which is connected to the dedicated spoke virtual network, supports a configurable number of data disks, pre-configured administrator credentials using key vault and pre-configured virtual machine extensions. The quick start implements [Performance guidelines for SQL Server on Azure Virtual Machines](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices) using a post-deployment script.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_db_name | Input | string | Local | winbenchdb01
vm_db_size | Input | string | Local | Standard_B4ms
vm_db_storage_replication_type | Input | string | Local | StandardSSD_LRS (Note: change this to "Premium_LRS" to observe best practices for Microsoft SQL Server.)
vm_db_image_publisher | Input | string | Local | MicrosoftSQLServer
vm_db_image_offer | Input | string | Local | sql2019-ws2019
vm_db_image_sku | Input | string | Local | sqldev
vm_db_image_version | Input | string | Local | Latest (default)
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
virtual_machine_03_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/winbenchdb01
virtual_machine_03_name | Output | string | Local | winbenchdb01

#### Database server network interface

[Virtual network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_03_nic_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-winbenchdb01-001
virtual_machine_03_nic_01_name | Output | string | Local | nic-winbenchdb01-001
virtual_machine_03_nic_01_private_ip_address | Output | string | Local | 10.2.1.36

#### Database server managed disks and data disk attachments

One or more [managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview) for use by the virtual machine as data disks. Each of the managed disks is automatically attached to the virtual machine with naming parity between the resource name for the managed disk and the volume label applied when the post-deployment script formats the disk. The default settings implement two data disks using a map variable named *vm_db_data_disk_config*, the value for which must follow these conventions:

* Data disk: "sqldata" (used for SQL Server data files)
  * name: Must follow the convention "vol_sqldata_\[driveletter\]", e.g. "vol_sqldata_F". Note drives A - E are reserved for use by Azure Virtual Machines.
  * disk_size_gb: e.g. "128"
  * Caching: "ReadOnly" as per best practices for Microsoft SQL Server.
  * lun: must be unique integer from 0 - 15, e.g. "0"
* Data disk: "sqllog" (used for SQL Server data files)
  * name: Must follow the convention "vol_sqllog_\[driveletter\]", e.g. "vol_sqllog_L". Note drives A - E are reserved for use by Azure Virtual Machines.
  * disk_size_gb: e.g. "32"
  * Caching: "None" as per best practices for SQL Server log files
  * lun: must be unique integer from 0 - 15, e.g. "1"

Note the post-deployment script has dependencies on these naming conventions, and also implements a 64K allocation unit size when formatting volumes as per best practices for SQL Server data and log files. The post deployment script also moves the SQL Server tempdb data and log files to the [Ephemeral OS disk](https://docs.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks) as per best practices for Microsoft SQL Server, and a scheduled task is created to run on system startup that re-creates the tempdb folders on the ephemeral drive.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_db_data_disk_config | Input | string | Local | { sqldata = { name = "vol_sqldata_F", disk_size_gb = "128", lun = "0", caching = "ReadOnly" }, sqllog = { name = "vol_sqllog_L", disk_size_gb = "32", lun = "1", caching = "None" } }
vm_storage_replication_type | Input | string | Local | StandardSSD_LRS (Note: change this to "Premium_LRS" to observe best practices for Microsoft SQL Server.)

#### SQL Server virtual machine resource provider configuration

The database virtual machine is registered with the [Microsoft.SqlVirtualMachine](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-vm-resource-provider-register) resource provider using the following defaults:

* *sa* username and password credentials set using key vault
* sql_license_type = "PAYG"
* r_services_enabled = true
* sql_connectivity_port = 1433
* sql_connectivity_type = "PRIVATE"

#### Database server virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the virtual machine including:

* [Log Analytics virtual machine extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows) also known as the *Microsoft Monitoring Agent* (MMA) version 1.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Dependency virtual machine extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-windows) version 9.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) version 1.10 with automatic minor version upgrades enabled and configured to run a post-deployment script installs software, configures data disks, and reconfigures SQL Server to follow reccomendations in [Performance guidelines for SQL Server on Azure Virtual Machines](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices).
* [SQL Server IaaS agent extension](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-iaas-agent-extension-automate-management) is automatically installed when the virtual machine is registered with the SQL Server virtual machine resource provider.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
storage_account_name | Input | String | Local | st8e644ec51c5be098001
vm_db_post_deploy_script_name | Input | string | Local | virtual-machine-03-post-deploy.ps1 (Default)
vm_db_post_deploy_script_uri | Input | string | Local | <https://st8e644ec51c5be098001.blob.core.windows.net/scripts/virtual-machine-03-post-deploy.ps1>

### App server virtual machine

---

App server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/) offering which is connected to the dedicated spoke virtual network with pre-configured administrator credentials using key vault, and pre-configured virtual machine extensions.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_app_name | Input | string | Local | winbenchapp01
vm_app_size | Input | string | Local | Standard_B2s
vm_app_storage_replication_type | Input | string | Local | Standard_LRS
vm_app_image_publisher | Input | string | Local | MicrosoftWindowsServer
vm_app_image_offer | Input | string | Local | WindowsServer
vm_app_image_sku | Input | string | Local | 2019-Datacenter-smalldisk
vm_app_image_version | Input | string | Local | Latest (default)
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
virtual_machine_04_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/winbenchapp01
virtual_machine_04_name | Output | string | Local | winbenchapp01

#### Web server network interface

[Virtual network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_04_nic_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-winbenchapp01-001
virtual_machine_04_nic_01_name | Output | string | Local | nic-winbenchapp01-001
virtual_machine_04_nic_01_private_ip_address | Output | string | Local | 10.2.1.68

#### Web server virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the virtual machine including:

* [Log Analytics virtual machine extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows) also known as the *Microsoft Monitoring Agent* (MMA) version 1.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Dependency virtual machine extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-windows) version 9.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) version 1.10 with automatic minor version upgrades enabled and configured to run a post-deployment script which partitions and formats new data disks.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
vm_app_post_deploy_script_name | Input | string | Local | virtual-machine-04-post-deploy.ps1 (Default)
vm_app_post_deploy_script_uri | Input | string | Local | <https://st8e644ec51c5be098001.blob.core.windows.net/scripts/virtual-machine-04-post-deploy.ps1>
storage_account_name | Input | String | Local | st8e644ec51c5be098001

## Smoke testing

* Explore newly provisioned resources using the Azure portal.
  * Review the 4 secrets that were created in the shared key vault.
  * Review the database server virtual machine configuration using both the *Virtual machine* UI and the *SQL virtual machine* UI.
  * Generate a script for mapping drives to the shared file share.
    * Mapping a drive to an Azure Files file share requires automation due to the use of a complex shared key to authenticate.
    * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx001* > *file service* > *file shares* > *fs-xxxxxxxxxxxxxxxx-001* > *Connect* > *Windows*
    * Copy the PowerShell script in the right-hand pane for use in the next smoke testing exercise.
* Connect to the database server virtual machine in the Azure portal using bastion and log in with the *adminuser* and *adminpassword* defined previously.
  * Confirm access to shared file share private endpoint.
    * Run Windows PowerShell ISE, create a new script, and paste in the script generated previously.
    * Copy the fqdn for the file endpoint from line 4, for example *stxxxxxxxxxxxxxxxx001.file.core.windows.net*
    * Run `Resolve-DnsName stxxxxxxxxxxxxxxxx001.file.core.windows.net` from the Windows PowerShell ISE console.  
    * Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-001* subnet in the shared services virtual network. This name resolution is accomplished using the shared private DNS zone.
    * Execute the PowerShell script copied from the Azure Portal to establish a drive mapping to the shared file share using the private endpoint.
    * Create some directories and sample files on the drive mapped to the shared file share to test functionality.
  * Review the log file created during execution of the post-deployment script in C:/Packages/Plugins/Microsoft.Compute.CustomScriptExtension/1.10.X/Downloads/0.
  * Launch SQL Server Management Studio and create a test database.

## Next steps

Move on to the next quick start [terraform-azurerm-vwan](../terraform-azurerm-vwan).
