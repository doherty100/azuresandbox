# Azure quick start configuration: terraform-azurerm-vm-windows  

## Overview

This quick start implements a jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/) offering. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 3 resources included in this quick start.

### Windows jump box virtual machine

---

Jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/) offering. The virtual machine is connected to the shared services virtual network with a configurable number of data disks, pre-configured administrator credentials using key vault, and pre-configured virtual machine extensions.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_name | Input | string | Local | winjump1
vm_size | Input | string | Local | Standard_B2s
vm_storage_account_type | Input | string | Local | Standard_LRS
vm_image_publisher | Input | string | Local | MicrosoftWindowsServer
vm_image_offer | Input | string | Local | WindowsServer
vm_image_sku | Input | string | Local | 2019-Datacenter
vm_image_version | Input | string | Local | Latest
virtual_machine_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/winjump1
virtual_machine_01_name | Output | string | Local | winjump1
virtual_machine_01_principal_id | Output | string | Local | 00000000-0000-0000-0000-000000000000

#### Network interface

Dedicated [network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the Windows jump box virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_01_nic_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-jumpbox01-001
virtual_machine_01_nic_01_name | Output | string | Local | nic-winjump1-001
virtual_machine_01_nic_01_private_ip_address | Output | string | Local | 10.1.0.4

#### Virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the Windows jump box virtual machine including:

* [Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) version 1.10 with automatic minor version upgrades enabled and configured to run a post-deployment script.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
app_vm_post_deploy_script_name | Input | string | Local | post-deploy-app-vm.ps1
app_vm_post_deploy_script_uri | Input | string | Local | <https://stbfde01d4ee60a358001.blob.core.windows.net/scripts/post-deploy-app-vm.ps1>
storage_account_name | Input | String | Local | st8e644ec51c5be098001

## Smoke testing

* Review the post-deployment script code in `post-deploy-app-vm.ps1`. Use the Azure portal to confirm the script was uploaded to blob storage.
* Explore newly provisioned resources using the Azure portal.
  * Review the 3 secrets that were created in the key vault.
  * Generate a script for mapping drives to the file share.
    * Mapping a drive to an Azure Files file share requires automation due to the use of a complex shared key to authenticate.
    * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx001* > *file service* > *file shares* > *fs-xxxxxxxxxxxxxxxx-001* > *Connect* > *Windows*
    * Copy the PowerShell script in the right-hand pane for use in the next smoke testing exercise.
* Connect to the virtual machine in the Azure portal using bastion and log in with the *adminuser* and *adminpassword* defined previously.
  * Confirm access to file share private endpoint.
    * Run Windows PowerShell ISE, create a new script, and paste in the script generated previously.
    * Copy the fqdn for the file endpoint from line 4, for example *stxxxxxxxxxxxxxxxx001.file.core.windows.net*
    * Run `Resolve-DnsName stxxxxxxxxxxxxxxxx001.file.core.windows.net` from the Windows PowerShell ISE console.  
    * Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-001* subnet in the shared services virtual network. This name resolution is accomplished using the private DNS zone.
    * Execute the PowerShell script copied from the Azure Portal to establish a drive mapping to the file share using the private endpoint.
    * Create some directories and sample files on the drive mapped to the file share to test functionality.
  * Review the log file created during execution of the post-deployment script in C:/Packages/Plugins/Microsoft.Compute.CustomScriptExtension/1.10.X/Downloads/0.

## Next steps

Move on to the following quick starts next:

* [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux) (optional)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
