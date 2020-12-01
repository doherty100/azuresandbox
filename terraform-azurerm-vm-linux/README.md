# Azure quick start configuration: terraform-azurerm-vm-linux

## Overview

This quick start implements a jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Linux virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/) offering. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

### Getting started with default settings

This section describes how to provision this quick start using default settings.

* Create required secrets in shared key vault and provision post-deployment script.
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines. See [What are the username requirements when creating a VM?](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq) for additional guidance.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password. See [What are the password requirements when creating a VM?](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm) for additional guidance.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `./run-gen-tfvarsfile.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

### Getting started with custom settings

This section describes how to provision this quick start using custom settings. Refer to [Perform custom quick start deployment](https://github.com/doherty100/azurequickstarts#perform-custom-quick-start-deployment) for more details.

* Create required secrets in shared key vault and provision post-deployment script.
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines. See [What are the username requirements when creating a VM?](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq) for additional guidance.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password. See [What are the password requirements when creating a VM?](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm) for additional guidance.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh`.
  * -n: Change to a custom *VM_NAME* if desired.
  * -p: Change to a different *VM_IMAGE_PUBLISHER* if desired.
    * Run `az vm image list-publishers` to get a list of publishers.
  * -o: Change to a different *VM_IMAGE_OFFER* if desired.
    * Run `az vm image list-offers` to get a list of offers.
  * -s: Change to a different *VM_IMAGE_SKU* if desired.
    * Run `az vm image list-skus` to get a list of image skus.
  * -z: Change to a different *VM_SIZE* if desired.
    * Run `az vm list-sizes` to get a list of available virtual machine sizes.
  * -c: Change to a different *VM_DATA_DISK_COUNT* if desired. Set to "0" of no data disks are required.
  * -d: Change to a different *VM_DATA_DISK_SIZE_GB* if desired.
  * -t: Change to a different *TAGS* map if desired.
  * Save changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

## Resource index

This section provides an index of the ~5 resources included in this quick start.

### Linux jump box virtual machine

---

Linux jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Linux virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/) offering. The virtual machine is connected to the dedicated hub virtual network with a configurable number of data disks, pre-configured administrator credentials using key vault, and pre-configured virtual machine extensions. Password authentication is enabled.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_name | Input | string | Local | jumpbox02
vm_size | Input | string | Local | Standard_B2s
vm_storage_replication_type | Input | string | Local | Standard_LRS
vm_image_publisher | Input | string | Local | Canonical
vm_image_offer | Input | string | Local | UbuntuServer
vm_image_sku | Input | string | Local | 18.04-LTS
vm_image_version | Input | string | Local | Latest (default)
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
virtual_machine_02_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/jumpbox02
virtual_machine_02_name | Output | string | Local | jumpbox02

#### Network interface

Dedicated [network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the Linux jump box virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_02_nic_01_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-jumpbox02-001
virtual_machine_02_nic_01_name | Output | string | Local | nic-jumpbox02-001
virtual_machine_02_nic_01_private_ip_address | Output | string | Local | 10.1.0.5

#### Managed disks and data disk attachments

One or more dedicated [managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview) for use by the Linux jump box virtual machine as data disks. Each of the dedicated managed disks is automatically attached to the virtual machine, but must be partitioned and mounted manually. Note that caching is disabled by default and must be configured post-deployment if needed. Performance optimization of managed disks for Linux guest operating systems vary widely by distribution, file system and workload. See [Optimize your Linux VM on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/optimization) for Azure specific best practices.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_data_disk_count | Input | string | Local | 0
vm_storage_replication_type | Input | string | Local | Standard_LRS
vm_data_disk_size_gb | Input | string | Local | 0 (Gb)

#### Virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the Linux jump box virtual machine including:

* [Log Analytics virtual machine extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-linux) also known as the *OMS Agent* version 1.13 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Dependency virtual machine extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-linux) version 9.10 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux) version 2.1 with automatic minor version upgrades enabled and configured to run a post-deployment script.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
post_deploy_script_name | Input | string | Local | virtual-machine-02-post-deploy.sh (Default)
post_deploy_script_uri | Input | string | Local | <https://stf7250f5be032d651001.blob.core.windows.net/scripts/virtual-machine-02-post-deploy.sh>
storage_account_name | Input | String | Local | stf7250f5be032d651001

## Smoke testing

* Review the post-deployment script code in `virtual-machine-02-post-deploy.sh`. Use the Azure portal to confirm the script was uploaded to shared blob storage container.
* Explore newly provisioned resources using the Azure portal.
  * Review the 4 secrets that were created in the shared key vault.
  * Generate a bash script for mapping drives to the shared file share.
    * Mapping a drive to an Azure Files file share requires automation due to the use of a complex shared key to authenticate.
    * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx001* > *file service* > *file shares* > *fs-xxxxxxxxxxxxxxxx-001* > *Connect* > *Linux*
    * Copy the bash script in the right-hand pane for use in the next smoke testing exercise.
* From the Azure portal, use bastion to open an SSH session with virtual machine and log in with the *adminuser* and *adminpassword* defined previously.
  * If you used custom settings and added data disks, you will need to partition and mount them. See [Connect to the Linux VM to mount the new disk](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/add-disk#connect-to-the-linux-vm-to-mount-the-new-disk) for more details.
  * Confirm access to shared file share private endpoint.
    * Create a new bash script, and paste in the script generated previously.
    * Copy the fqdn for the file endpoint, for example *stxxxxxxxxxxxxxxxx001.file.core.windows.net*
    * Run `dig stxxxxxxxxxxxxxxxx001.file.core.windows.net` and examine the *ANSWER* section. Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-001* subnet in the shared hub virtual network. This name resolution is accomplished using the shared private DNS zone.
    * Execute the bash script copied from the Azure Portal to mount the shared file share using the private endpoint.
    * Create some directories and sample files on the mount point associated with the shared file share to test functionality.
  * Review the log file created during execution of the post-deployment script in `/var/lib/waagent/custom-script/download/0/`.
  
## Next steps

Move on to the following quick starts next:

* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) (optional)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
