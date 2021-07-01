# Azure quick start configuration: terraform-azurerm-vm-sql  

## Overview

This quick start implements an [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) database server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) using a [SQL Server virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview#payasyougo) offering. This virtual machine can be used to host databases for applications or to run benchmarks like [HammerDB](https://www.hammerdb.com/). The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~10 minutes
Smoke testing | ~15 minutes
De-provisioning | ~5 minutes

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 7 resources included in this quick start.

### Database server virtual machine

---

The database server virtual machine is provisioned using a [SQL Server virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview#payasyougo) offering. Post-deployment scripts are used to implement the recommendations in [Checklist: Best practices for SQL Server on Azure VMs](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist). This quick start does not register the new SQL Server instance with the [Microsoft.SqlVirtualMachine](https://docs.microsoft.com/en-us/azure/templates/microsoft.sqlvirtualmachine/sqlvirtualmachines?tabs=json) resource provider using the [azurerm_mssql_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine) resource. This is intentional. Bringing this resource under Terraform management can significantly complicate applying changes to Terraform configurations because it needs to maintain data plane connectivity to the SQL Server instance installed on the VM. If you wish to use this resource provider you should enable [Automatic registration with SQL IaaS Agent extension](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-agent-extension-automatic-registration-all-vms?tabs=azure-cli).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_db_name | Input | string | Local | winsqldb01
vm_db_size | Input | string | Local | Standard_B4ms
vm_db_storage_account_type | Input | string | Local | StandardSSD_LRS (Note: change this to "Premium_LRS" to observe best practices for Microsoft SQL Server.)
vm_db_image_publisher | Input | string | Local | MicrosoftSQLServer
vm_db_image_offer | Input | string | Local | sql2019-ws2019
vm_db_image_sku | Input | string | Local | sqldev
vm_db_image_version | Input | string | Local | Latest

#### Network interface

[Virtual network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the virtual machine.

#### Managed disks and data disk attachments

One or more [managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview) for use by the virtual machine as data disks. Each of the managed disks is automatically attached to the virtual machine with naming parity between the resource name for the managed disk and the volume label applied when the post-deployment script formats the disk. The default settings implement two data disks using a map variable named *vm_db_data_disk_config*, the value for which must follow these conventions:

* Data disk: "sqldata" (used for SQL Server data files)
  * name: Must follow the convention "vol_sqldata_\[driveletter\]", e.g. "vol_sqldata_M". Note drives A - E are reserved for use by Azure Virtual Machines.
  * disk_size_gb: e.g. "128"
  * Caching: "ReadOnly" as per best practices.
  * lun: must be unique integer from 0 - 15, e.g. "0"
* Data disk: "sqllog" (used for SQL Server data files)
  * name: Must follow the convention "vol_sqllog_\[driveletter\]", e.g. "vol_sqllog_L". Note drives A - E are reserved for use by Azure Virtual Machines.
  * disk_size_gb: e.g. "32"
  * Caching: "None" as per best practices.
  * lun: must be unique integer from 0 - 15, e.g. "1"

Note the post-deployment script has dependencies on these naming conventions, and implements the storage recommendations in [Checklist: Best practices for SQL Server on Azure VMs](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist) including:

* Volumes are formatted using a a 64K allocation unit size
* SQL Server tempdb data and log files are moved to the local temporary disk.
* A scheduled task is created to run on system startup that re-creates the required directories on the local temporary disk if  the VM is [deallocated](https://docs.microsoft.com/en-us/azure/virtual-machines/states-billing#power-states-and-billing). For this reason use of an [Azure VM sizes with no local temporary disk](https://docs.microsoft.com/en-us/azure/virtual-machines/azure-vms-no-temp-disk) should be avoided for a SQL Server virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_db_data_disk_config | Input | string | Local | { sqldata = { name = "vol_sqldata_M", disk_size_gb = "128", lun = "0", caching = "ReadOnly" }, sqllog = { name = "vol_sqllog_L", disk_size_gb = "32", lun = "1", caching = "None" } }
vm_storage_account_type | Input | string | Local | StandardSSD_LRS (Note: change this to "Premium_LRS" to observe best practices for Microsoft SQL Server.)

#### Virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the virtual machine.

##### Custom script extension

[Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) version 1.10 with automatic minor version upgrades enabled and configured to upload PowerShell scripts which configure data disks and SQL Server. Note these scripts have only been tested with the *sql2019-ws2019* image offer.

* [post-deploy-sql-vm.ps1](./post-deploy-sql-vm.ps1): This is the initial script run by the custom script extension and runs under LocalSystem. It's only function is to launch sql-bootstrap.ps1 with elevated privileges.
* [sql-bootstrap.ps1](./sql-bootstrap.ps1): This script is designed to run as a local administrator and configures SQL Server according to the recommendations in [Checklist: Best practices for SQL Server on Azure VMs](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist).
* [sql-startup.ps1](./sql-startup.ps1): This script is used as a scheduled task during startup to recreate directories on the local temporary disk and start SQL Server if the VM is deallocated.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_account_name | Input | String | Local | st8e644ec51c5be098001
vm_db_post_deploy_script | Input | string | Local | post-deploy-sql-vm.ps1
vm_db_post_deploy_script_uri | Input | string | Local | <https://st4f68ad5fe009d4d8001.blob.core.windows.net/scripts/post-deploy-sql-vm.ps1>
vm_db_sql_bootstrap_script | Input | string | Local | sql-bootstrap.ps1
vm_db_sql_bootstrap_script_script_uri | Input | string | Local | <https://st4f68ad5fe009d4d8001.blob.core.windows.net/scripts/sql-bootstrap.ps1>
vm_db_sql_startup_script | Input | string | Local | sql-startup.ps1
vm_db_sql_startup_script_uri | Input | string | Local | <https://st4f68ad5fe009d4d8001.blob.core.windows.net/scripts/sql-startup.ps1>

## Smoke testing

* Explore newly provisioned resources using the Azure portal.
  * Review the 4 secrets that were created in the shared key vault.
  * Review the database server virtual machine configuration using both the *Virtual machine* UI and the *SQL virtual machine* UI.
  * Generate a script for mapping drives to the shared file share.
    * Mapping a drive to an Azure Files file share requires automation due to the use of a complex shared key to authenticate.
    * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx001* > *file service* > *file shares* > *fs-xxxxxxxxxxxxxxxx-001* > *Connect* > *Windows*
    * Copy the PowerShell script in the right-hand pane for use in the next smoke testing exercise.
* Connect to the database server virtual machine in the Azure portal using bastion and log in with the value of the *adminuser* secret (e.g. `bootstrapadmin`) and the value of the *adminpassword* secret defined previously.
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

Move on to the next quick start [terraform-azurerm-sql](../terraform-azurerm-sql).
