# Azure quick start configuration: terraform-azurerm-vm-windows  

## Overview

This quick start implements a dedicated Windows Server virtual machine which can be used as a jump box, admin workstation, web server, application server or database server. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-hub](../terraform-azurerm-vnet-hub)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

## Getting started

* Create required secrets in shared key vault
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Note that the password must be at least 12 characters long and meet [defined complexity requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm). Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./setkeyvaultsecrets.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh` and update the following parameters:  
  * Customize parameter values as needed.
  * Save your changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

## Resource index

This section provides an index of the ~6 resources included in this quick start.

### Virtual machine

---

Dedicated Windows Server virtual machine with a configurable number of data disks, pre-configured administrator credentials using key vault, and pre-configured virtual machine extensions.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_name | Input | string | Local | jumpbox01
vm_size | Input | string | Local | Standard_B2ms
vm_storage_replication_type | Input | string | Local | Standard_LRS
vm_image_publisher | Input | string | Local | MicrosoftWindowsServer
vm_image_offer | Input | string | Local | WindowsServer
vm_image_sku | Input | string | Local | 2019-Datacenter-smalldisk
vm_image_version | Input | string | Local | Latest (default)
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
virtual_machine_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/jumpbox01
virtual_machine_01_name | Output | string | Local | jumpbox01

#### Network interface

Dedicated [network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the dedicated Windows Server virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_01_nic_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-jumpbox01-001
virtual_machine_01_nic_01_name | Output | string | Local | nic-jumpbox01-001
virtual_machine_01_nic_01_private_ip_address | Output | string | Local | 10.2.0.4

#### Managed disks and data disk attachments

One or more dedicated [managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview) for use by the dedicated Windows Server virtual machine as data disks. Note the data disks are created empty and must be partitioned and formatted manually before use. Each of the dedicated managed disks is automatically attached to the dedicated Windows Server virtual machine. Note that caching is disabled by default and must be configured post-deployment if needed.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_data_disk_count | Input | string | Local | 1
vm_storage_replication_type | Input | string | Local | Standard_LRS
vm_data_disk_size_gb | Input | string | Local | 32 (Gb)

#### Virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the dedicated Windows Server virtual machine and connected to the shared log analytics workspace using secrets from the shared key vault, including:

* [Log Analytics virtual machine extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows) also known as the *Microsoft Monitoring Agent* (MMA) version 1.0 with automatic minor version upgrades enabled.
* [Dependency virtual machine extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-windows) version 9.0 with automatic minor version upgrades enabled.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_id | Input | string | Local | 00000000-0000-0000-0000-000000000000

## Smoke testing

* Examine shared secrets.
  * Use the Azure portal to review the 3 secrets that were created in the shared key vault.
* Create a script for mapping drives to the shared file share.
  * Mapping a drive to an Azure Files file share requires automation due to the use of a complex shared key to authenticate.
  * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx001* > *file service* > *file shares* > fs-xxxxxxxxxxxxxxxx-001 > Connect > Windows
  * Copy the PowerShell script in the right-hand pane for use in the next smoke testing exercise.
* Connect to the dedicated virtual machine in the Azure portal using bastion and log in with the *adminuser* and *adminpassword* defined previously.
  * Partition and format the data disks attached to the virtual machine.
  * Confirm access to shared file share private endpoint.
    * Run PowerShell ISE and paste in the PowerShell script generated in the previous smoke testing exercise.
    * Copy the fqdn for the file endpoint from line 4, for example *stxxxxxxxxxxxxxxxx001.file.core.windows.net*
    * Run `Resolve-DnsName stxxxxxxxxxxxxxxxx001.file.core.windows.net` from the PowerShell ISE console.  
      * Note the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-001* subnet in the shared hub virtual network. This name resolution is accomplished via the shared private DNS zone.
    * Execute the PowerShell script copied from the Azure Portal to establish a drive mapping to the shared file share using the private endpoint.
  * Create some directories and sample files on the drive mapped to the shared file share to test functionality.

## Next steps

Move on to the next quick start [terraform-azurerm-vwan](../terraform-azurerm-vwan).
