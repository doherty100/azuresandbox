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

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 2 resources included in this quick start.

### Linux jump box virtual machine

---

Linux jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Linux virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/) offering. The virtual machine is connected to the shared services virtual network with pre-configured administrator credentials using key vault and pre-configured virtual machine extensions. Password authentication is enabled. The [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) is automatically installed using [cloud-init](https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/cloud-init-support-linux-vms).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_name | Input | string | Local | ubuntu-jumpbox-02
vm_size | Input | string | Local | Standard_B2s
vm_storage_account_type | Input | string | Local | Standard_LRS
vm_image_publisher | Input | string | Local | Canonical
vm_image_offer | Input | string | Local | UbuntuServer
vm_image_sku | Input | string | Local | 18.04-LTS
vm_image_version | Input | string | Local | Latest
ssh_public_key | Input | string | Local | ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCt5TD/JXCa6YLzJgZKYqemVeQKlHj6OsOl+TIuR6lWgt0qauu9cKnThcaQc64HXj9cU2IB8t21mocsCt7Ul+y8+JB5XgqqRFdK9aQ+oMZBhGhv5gd20iqJ+pcxGEnl9stsBaOqbptVI0OhuDMLcGxRt+k3dAmfgOvCLhx+Lb7T/IJ/XNYDrGCUlWNF+ldlCWIbOkVKusQ6jFk9+cNlbOCrehMpaIG0Uwi3hyT5NmvazL1dLDcZ72SVFXC3YAQBBiK5XxOMiOvqrE+u2FyZxje8kOXxD5iycMOWkyJevsCYCkQeIWVHBWxLlFT08GHsyP6Vgv3kx5wkhxMrOZrTGB9HrB9MbMoZnzGGfH5NdKBW8Xq9Q+ENlb8vg156u+Q0e+dhrdKqRDXA0xBOUI4XWDyvS0vuXaqF4M4kd7lvXnklGyeUKQurmXqw0CaDE67Y7akNfolQjDoCa2hPvsYRCadypbP5i3+K0BZYc9JYIvKcxLyGf0H1JqojJ/nrXSd0lqOaOqvSxkg+PqplbDEiNlda5QiGzF6fnUaimDXcocViEgh45wibUuq+XXa4hEYcgm8c+OVNT7inSz8ToypkIcCiEaVKN+yoP52ZQXY6Roiariv5kPzs/bCYtRe3L07h7thB7LoG1I7yf6+PRj7y2d6lA2x1TEnquD92uTVUKuzoQ== bootstrapadmin
virtual_machine_02_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Compute/virtualMachines/ubuntu-jumpbox-02
virtual_machine_02_name | Output | string | Local | ubuntu-jumpbox-02
virtual_machine_02_principal_id | Output | string | Local | 00000000-0000-0000-0000-000000000000

#### Network interface

Dedicated [network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_02_nic_01_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/networkInterfaces/nic-ubuntu-jumpbox-02
virtual_machine_02_nic_01_name | Output | string | Local | nic-ubuntu-jumpbox-02
virtual_machine_02_nic_01_private_ip_address | Output | string | Local | 10.1.0.5

## Smoke testing

* Review the [cloud-init](https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/cloud-init-support-linux-vms) configuration code in `cloud-init.yaml`.
  * Review the log file created during cloud-init execution at `/var/log/cloud-init-output.log`.
* Explore newly provisioned resources using the Azure portal.
  * Generate a bash script for mapping drives to the shared file share.
    * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx01* > *file service* > *file shares* > *fs-xxxxxxxxxxxxxxxx-01* > *Connect* > *Linux*
    * Copy the bash script in the right-hand pane for use in the next smoke testing exercise.
* From the Azure portal, use bastion to open an SSH session with virtual machine using the values stored in the following key vault secrets:
  * User: `adminuser`
  * SSH Private Key: `bootstrapadmin-ssh-key-private`
  * Advanced > SSH Passphrase: `adminpassword`
* Confirm access to file share private endpoint.
  * Create a new bash script, and paste in the script generated previously.
  * Copy the fqdn for the file endpoint, for example *stxxxxxxxxxxxxxxxx01.file.core.windows.net*
  * Run `dig stxxxxxxxxxxxxxxxx01.file.core.windows.net` and examine the *ANSWER* section. Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-01* subnet in the shared services virtual network. This name resolution is accomplished using the shared private DNS zone.
  * Execute the bash script copied from the Azure Portal to mount the shared file share using the private endpoint.
  * Create some directories and sample files on the mount point associated with the file share to test functionality.
  
## Next steps

Move on to the following quick starts next:

* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) (optional)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
