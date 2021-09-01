# #AzureQuickStarts - terraform-azurerm-vnet-shared  

## Overview

![vnet-shared-diagram](./vnet-shared-diagram.png)

This quick start implements a virtual network with shared services used by all the quick starts including:

* A [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group) for provisioning Azure resources
* A [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) for storing and retrieving shared secrets
* A [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account) for storing and retrieving data
* A [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/data-platform#collect-monitoring-data) for storing and querying metrics and logs
* An [automation account](https://docs.microsoft.com/en-us/azure/automation/automation-intro) for [Azure automation state configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview)
* A [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) for hosting virtual machines used as domain controllers, DNS servers and jump boxes.
* A [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) for secure RDP and SSH access to virtual machines.
* A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) running [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) with a pre-configured domain and DNS server.

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~30 minutes
Smoke testing | ~10 minutes
De-provisioning | ~30 minutes

## Before you start

Before you start, make sure you have completed the following steps:

* All [Prerequisites](../README.md#Prerequisites) must be completed.
  * The Azure subscription owner must create a service principle with a *Contributor* Azure RBAC role assignment in advance.
  * The *appId* and *password* of the service principle must be shared with the quick start user in advance.
  * The quick start user must also have a *Contributor* role assignment on the Azure subscription.
* Complete the steps in [Configure client environment](../README.md#configure-client-environment).
  * Verify you can start a new Bash terminal session
  * Verify the Azure CLI is installed by running `az version`
  * Verify PowerShell is installed by running `pwsh` then `exit`
  * Verify you have cloned a copy of the GitHub repo with the latest release of the quick start code.

## Getting started

This section describes how to provision this quick start using default settings.

* Start a new Bash terminal session.
* Run `az logout` and `az account clear` to reset the user credentials used by Azure CLI.
* Run `az login` and sign in using the identity you intend to use for the quick starts.
* Run `az account list -o table` and copy the *Subscription Id* to be used for the quick starts.
* Run `az account set -s 00000000-0000-0000-0000-000000000000` using the *Subscription Id* from the previous step to set the default subscription.
* Run `./bootstrap.sh` using the default settings or your own custom settings.
  * When prompted for *arm_client_id*, use the *appId* for the service principle created by the subscription owner.
  * When prompted for *adminuser*, avoid using [restricted usernames](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm-).
  * When prompted for *adminpassword*, generate a strong password but be sure to escape any [linux special characters](https://tldp.org/LDP/abs/html/special-chars.html).
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
  * When prompted for *arm_client_secret*, use the *password* for the service principle created by the subscription owner.
* Run `terraform apply` to apply the plan.
  * When prompted for *arm_client_secret*, use the *password* for the service principle created by the subscription owner.

## Smoke testing

* Explore your newly provisioned resources in the Azure portal.
* Use bastion to establish an RDP connection to the Windows Server virtual machine.
* Launch the *Active Directory Domains and Trusts* administration tool and verify the newly configured domain name.
* Launch the *DNS Manager* administration tool and examine the `Forward Lookup Zones` node to understand the default dns configuration of the newly configured domain.
* Run `terraform output` to view the output variables from the *terraform.tfstate* file.

## Next steps

* Move on to the next quick start [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) and/or [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux).

## Documentation

This section provides additional information on various aspects of this quick start.

### Bootstrap script

In most real world projects, Terraform configurations must refer to existing resources that have been provisioned and configured in advance and are referenced but not included in the configuration. It is also sometimes necessary to provision resources in advance to avoid a circular dependency in your configurations. For this reason, there are several resources provisioned in this quick start that are not included in the Terraform configurations. The Bash script [bootstrap.sh](./bootstrap.sh) used in this quick start performs the following functions:

* Creates a new resource group used by all the quick starts.
* Creates a key vault, shared secrets and access policies.
* Creates a storage account and container.
* Creates a *terraform.tfvars* file for generating and applying Terraform plans.

The script is idempotent and can be run multiple times in a non-destructive fashion.

### Resources

The section lists the resources included in the Terraform configurations in this quick start.

Terraform resource name | Example ARM resource name | Notes
--- | --- | ---
data.azurerm_key_vault_secret.adminpassword | N/A | Used when administrative credentials are required to provision resources.
data.azurerm_key_vault_secret.adminuser | N/A | Used when administrative credentials are required to provision resources.
azurerm_automation_account.automation_account_01 | auto-c945545882b6597f-01 | Used for [Azure automation state configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview). Uses a Terraform [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) for configuration via [configure-automation.ps1](./configure-automation.ps1).
azurerm_bastion_host.bastion_host_01 | bst-d629fdbde51aca2a-1 | Used for secure RDP and SSH access to VMs
azurerm_key_vault_secret.log_analytics_workspace_01_primary_shared_key | N/A | Used to write data to a log analytics workspace
azurerm_log_analytics_workspace.log_analytics_workspace_01 | log-7b93173ee968ee33-01 | Used for services that require a log analytics workspace such as [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)
azurerm_network_interface.vm_adds_nic_01 | nic-adds1-1 | Nic with a private IP used for the adds1 VM
azurerm_public_ip.bastion_host_01 | pip-fc0b6ba367b0c212-1 | Public ip used by bastion
azurerm_subnet.vnet_shared_01_subnets["AzureBastionSubnet"] | N/A | Dedicated subnet for bastion
azurerm_subnet.vnet_shared_01_subnets["adds"] | N/A | Dedicated subnet for AD Domain Services
azurerm_subnet.vnet_shared_01_subnets["default"] | N/A | Default subnet for use by jumpbox VMs in other quick starts.
azurerm_virtual_network.vnet_shared_01 | vnet-shared-01 | Virtual network
azurerm_windows_virtual_machine.vm_adds | adds1 | Windows Server VM used for AD Domain Services. Uses a Terraform [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) for configuration via [configure-vm-adds.ps1](./configure-vm-adds.ps1).
random_id.automation_account_01_name | N/A | Used to generate a random name for the automation account.
random_id.bastion_host_01_name | N/A | Used to generate a random name for the bastion.
random_id.log_analytics_workspace_01_name | N/A | Used to generate a random name for the log analytics workspace.
random_id.public_ip_bastion_host_01_name | N/A | Used to generate a random name for the bastion.

### Output variables

This section lists the output variables defined in the Terraform configurations in this quick start. Some of these may be used for automation in other quick starts.

Variable name | Example value
--- | ---
aad_tenant_id | "00000000-0000-0000-0000-000000000000"
automation_account_01_name | "auto-9a633c2bba9351cc-01"
key_vault_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.KeyVault/vaults/kv-XXXXXXXXXXXXXXX"
key_vault_name | "kv-XXXXXXXXXXXXXXX"
location | "eastus2"
log_analytics_workspace_01_name | "log-XXXXXXXXXXXXXXXX-01"
log_analytics_workspace_01_workspace_id | "00000000-0000-0000-0000-000000000000"
resource_group_name | "rg-vdc-nonprod-01"
storage_account_name | "stXXXXXXXXXXXXXXX"
subscription_id | "00000000-0000-0000-0000-000000000000"
vnet_shared_01_default_subnet_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01/subnets/snet-default-01"
