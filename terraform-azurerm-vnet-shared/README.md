# #AzureQuickStarts - terraform-azurerm-vnet-shared  

## Overview

![vnet-shared-diagram](./vnet-shared-diagram.png)

This quick start implements a virtual network with shared services used by all the quick starts including:

* A [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group) for provisioning Azure resources
* A [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) for storing and retrieving shared secrets
* An [automation account](https://docs.microsoft.com/en-us/azure/automation/automation-intro) for [Azure automation state configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview)
* A [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) for hosting virtual machines used as domain controllers, DNS servers and jump boxes.
* A [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) for secure RDP and SSH access to virtual machines.
* A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) running [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) with a pre-configured domain and DNS server.
* A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) for use as a jumpbox.
* A Linux [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) for use as a jumpbox.
* A [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/data-platform#collect-monitoring-data) for storing and querying metrics and logs
* A [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account) for storing and retrieving data

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~30 minutes
Smoke testing | ~10 minutes
De-provisioning | ~30 minutes

## Before you start

Before you start, make sure you have completed the following steps:

* All [Prerequisites](../README.md#Prerequisites) must be completed.
  * The Azure subscription owner must create a service principal with a *Contributor* Azure RBAC role assignment in advance.
  * The *appId* and *password* of the service principal must be known.
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
  * When prompted for *arm_client_id*, use the *appId* for the service principal created by the subscription owner.
  * When prompted for *adminuser*, avoid using [restricted usernames](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm-).
  * When prompted for *adminpassword*, generate a strong password but be sure to escape any [linux special characters](https://tldp.org/LDP/abs/html/special-chars.html).
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
  * When prompted for *arm_client_secret*, use the *password* for the service principal created by the subscription owner.
* Run `terraform apply` to apply the plan.
  * When prompted for *arm_client_secret*, use the *password* for the service principal created by the subscription owner.
* Run `terraform state list` to list the resources managed in the configuration.
* Run `terraform output` to view the output variables from the *terraform.tfstate* file.

## Smoke testing

* Explore your newly provisioned resources in the Azure portal.
  * Navigate to *Automation Accounts* > [My Automation Account] > *State configuration (DSC)*. Refresh the data on the *Nodes* tab and verify that all nodes are compliant. Review the data in the *Configurations* and *Compiled configurations* tabs as well.
* Use bastion to establish an RDP connection to the Windows Server jumpbox virtual machine.
  * Verify the machine is domain joined
  * Review the network configuration by running `ipconfig /all` from the command prompt.
  * Ping the domain controller to verify connectivity.
  * Inspect the configuration of the domain using the *Active Directory Domains and Trusts*, *Active Directory Sites and Services* and *Active Directory Users and Computers* remote server administration tools.
  * Inspect the configuration of the DNS server using the *DNS* remote server administration tool.
  * Install [Visual Studio Code](https://aka.ms/vscode) and the [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension.
  * Configure Visual Studio Code to connect to the Linux jumpbox using Remote-SSH. See [Improving your security with a dedicated key](https://code.visualstudio.com/docs/remote/troubleshooting#_improving-your-security-with-a-dedicated-key) for more info.
    * The SSH keys can be found in the key vault secrets *bootstrapadmin-ssh-key-private* and *bootstrapadmin-ssh-key-public*. Here is a sample SSH configuration file to get you started:

    ```yaml
    Host 10.1.0.4
      HostName 10.1.0.4
      User bootstrapadmin
      IdentityFile C:\\Users\\bootstrapadmin\\.ssh\\bootstrap-admin-ssh-key-private
    ```

    * In VS Code, open the folder `/home/bootstrapadmin/` on the Linux Jumpbox.
    * In VS Code, open a Bash terminal and verify the Linux distribution and version by running the command `cat \etc\*-release`.

## Documentation

This section provides additional information on various aspects of this quick start.

### Bootstrap script

In most real world projects, Terraform configurations will need to reference resources that already exist and are not being managed by Terraform. It is also sometimes necessary to provision resources in advance to avoid circular dependencies in your Terraform configurations. For this reason, this quick start provisions several resources in advance using [bootstrap.sh](./bootstrap.sh) which does the following:

* Creates a new resource group used by all the quick starts.
* Creates a key vault, shared secrets and access policies.
* Creates a storage account and container.
* Creates a *terraform.tfvars* file for generating and applying Terraform plans.

The script is idempotent and can be run multiple times even after the Terraform configuration has been applied.

### Terraform Resources

The section lists the resources included in the Terraform configurations in this quick start.

#### Azure Automation Account

The configuration for these resources can be found in [030-automation.tf](./030-automation.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_automation_account.automation_account_01 (auto&#x2011;a9866e235174ab6a&#x2011;01) | See below.
random_id.automation_account_01_name | Used to generate a random unique name for *azurerm_automation_account.automation_account_01*

This quick start makes extensive use of [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview) to configure virtual machines using Terraform [Provisioners](https://www.terraform.io/docs/language/resources/provisioners/syntax.html).

* [configure-automation.ps1](./configure-automation.ps1): This script is run by a provisioner in the *azurerm_automation_account.automation_account_01* resource and does the following:
  * Updates [Azure Automation shared resources](https://docs.microsoft.com/en-us/azure/automation/automation-intro#shared-resources) including:
    * Updates [Modules](https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules) to the latest versions.
    * Imports the [ActiveDirectoryDsc](https://github.com/dsccommunity/ActiveDirectoryDsc) module.
    * Bootstraps [Variables](https://docs.microsoft.com/en-us/azure/automation/shared-resources/variables)
    * Bootstraps [Credentials](https://docs.microsoft.com/en-us/azure/automation/shared-resources/credentials)
  * Configures [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview)
    * Imports [DSC Configurations](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-getting-started#create-a-dsc-configuration)
      * [LabDomainConfig.ps1](./LabDomainConfig.ps1): configure as Windows Server virtual machine as an [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) [Domain Controller](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc786438(v=ws.10)).
      * [JumpBoxConfig.ps1](./JumpBoxConfig.ps1): configures a Windows Server virtual machine as jumpbox.
        * Domain joins the virtual machine
        * Installs [Remote Server Administration Tools (RSAT)](https://docs.microsoft.com/en-us/troubleshoot/windows-server/system-management-components/remote-server-administration-tools) including:
          * Active Directory module for Windows PowerShell
          * Active Directory Domain Services (AD DS) tools
    * [Compiles DSC Configurations](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-compile) so they can be used later to [Register a VM to be managed by State Configuration](https://docs.microsoft.com/en-us/azure/automation/tutorial-configure-servers-desired-state#register-a-vm-to-be-managed-by-state-configuration).

#### Network resources

The configuration for these resources can be found in [040-network.tf](./040-network.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_virtual_network.vnet_shared_01 (vnet&#x2011;shared&#x2011;01) | By default this virtual network is configured with an address space of 10.1.0.0/16 and DNS server  DNS server addresses of 10.1.2.4 (the private ip for *azurerm_windows_virtual_machine.vm_adds*) and [168.63.129.16](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16).)
azurerm_subnet.vnet_shared_01_subnets["default"] | The default address prefix for this subnet is 10.1.0.0/24 and includes the private ip address for *azurerm_windows_virtual_machine.vm_jumpbox_win*.
azurerm_subnet.vnet_shared_01_subnets["AzureBastionSubnet"] | The default address prefix for this subnet is 10.1.1.0/27 and includes the private ip addresses for *azurerm_bastion_host.bastion_host_01*.
azurerm_subnet.vnet_shared_01_subnets["adds"] | The default address prefix for this subnet is 10.1.2.0/24 and includes the private ip address for *azurerm_windows_virtual_machine.vm_adds*.
azurerm_bastion_host.bastion_host_01 (bst&#x2011;d629fdbde51aca2a&#x2011;1) | Used for secure RDP and SSH access to VMs.
random_id.bastion_host_01_name | Used to generate a random name for *azurerm_bastion_host.bastion_host_01*.
azurerm_public_ip.bastion_host_01 (pip&#x2011;fc0b6ba367b0c212&#x2011;1) | Public ip used by *azurerm_bastion_host.bastion_host_01*.
random_id.public_ip_bastion_host_01_name | Used to generate a random name for *azurerm_public_ip.bastion_host_01*.

#### AD DS Domain Controller VM

The configuration for these resources can be found in [050-vm-adds.tf](./050-vm-adds.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_windows_virtual_machine.vm_adds (adds1) | See below.
azurerm_network_interface.vm_adds_nic_01 (nic&#x2011;adds1&#x2011;1) | The configured subnet is *azurerm_subnet.vnet_shared_01_subnets["adds"]*.

This Windows Server VM is used as an AD DS Domain Controller and DNS Server.

* Guest OS: Windows Server 2019 Core
* By default the [Patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByPlatform`.
* *admin_username* and *admin_password* are configured using key vault secrets *data.azurerm_key_vault_secret.adminpassword* and *data.azurerm_key_vault_secret.adminuser* which are set in advance by [bootstrap.sh](./bootstrap.sh).
* This resource has a dependency on *azurerm_automation_account.automation_account_01*.
* This resource is configured using a [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) that runs [configure-vm-adds.ps1](./configure-vm-adds.ps1) which registers the node with *azurerm_automation_account.automation_account_01* and applies the configuration [LabDomainConfig](./LabDomainConfig.ps1).

#### Windows Server Jumpbox VM

The configuration for these resources can be found in [060-vm-jumpbox-win.tf](./060-vm-jumpbox-win.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_windows_virtual_machine.vm_jumpbox_win (jumpboxwin1) | See below.
azurerm_network_interface.vm_jumpbox_win_nic_01 (nic&#x2011;jumpwin1&#x2011;1) | The configured subnet is *azurerm_subnet.vnet_shared_01_subnets["default"]*.

This Windows Server VM is used as a jumpbox for development and remote server administration.

* Guest OS: Windows Server 2019 Datacenter.
* By default the [patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByPlatform`.
* *admin_username* and *admin_password* are configured using key vault secrets *data.azurerm_key_vault_secret.adminpassword* and *data.azurerm_key_vault_secret.adminuser* which are set in advance by [bootstrap.sh](./bootstrap.sh).
* This resource is configured using a [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) that runs [configure-vm-jumpbox.ps1](./configure-vm-jumpbox.ps1) which registers the node with *azurerm_automation_account.automation_account_01* and applies the configuration [JumpBoxConfig](./JumpBoxConfig.ps1).

#### Linux Jumpbox VM

The configuration for these resources can be found in [070-vm-jumpbox-linux.tf](./070-vm-jumpbox-linux.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_linux_virtual_machine.vm_jumpbox_linux | See below.
azurerm_network_interface.vm_jumbox_linux_nic_01 | The configured subnet is *azurerm_subnet.vnet_shared_01_subnets["default"]*.

This Linux VM is used as a jumpbox for development and remote administration.

* Guest OS: Ubuntu 20.04 LTS (Focal Fossa)
* This resource is configured using [cloud-init](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init#:~:text=%20There%20are%20two%20stages%20to%20making%20cloud-init,is%20already%20configured%20to%20use%20cloud-init.%20More%20) and the configuration is defined in [cloud-init.yaml](./cloud-init.yaml) which installs the following packages:
  * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest)
  * [Terraform](https://www.terraform.io/intro/index.html#what-is-terraform-)
  * [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1)

#### Log Analytics Workspace ID

The configuration for these resources can be found in [020-loganalytics.tf](./020-loganalytics.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_log_analytics_workspace.log_analytics_workspace_01 (log&#x2011;9d8828d28e2c73b7&#x2011;01) | General purpose log analytics workspace for use with services like [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) and [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/security-center-introduction).
random_id.log_analytics_workspace_01_name | Used to generate a random unique name for *azurerm_log_analytics_workspace.log_analytics_workspace_01*.
azurerm_key_vault_secret.log_analytics_workspace_01_primary_shared_key | Secret used to access *azurerm_log_analytics_workspace.log_analytics_workspace_01*.

### Terraform output variables

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

## Known issues

This section documents known issues with this quick start.

* Authentication: This quick start uses a service principal to authenticate with Azure which requires a client secret to be shared. This was due to the requirement that the quick start users be limited to a Contributor Azure RBAC role assignment which cannot do Azure RBAC role assignments. Real world projects should consider using [managed identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) instead of service principals which eliminates the need to share client secrets.
* Credentials: For simplicity, the quick starts use a single set of credentials when administrator accounts are required to provision or configure resources. In real world scenarios these credentials would be different for improved security posture.
* *azurerm_subnet.vnet_shared_01_subnets["adds"]*: Should be protected by an NSG as per best practices described in [Deploy AD DS in an Azure virtual network]
* *azurerm_windows_virtual_machine.vm_adds*
  * High availability: The current design uses a single VM for AD DS which is counter to best practices as described in [Deploy AD DS in an Azure virtual network](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/identity/adds-extend-domain) which recommends a pair of VMs in an Availability Set.
  * Data integrity: The current design hosts the AD DS domain forest data on the OS Drive which is counter to  best practices as described in [Deploy AD DS in an Azure virtual network](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/identity/adds-extend-domain) which recommends hosting them on a separate data drive with different cache settings.
* *configure-automation.ps1*: The performance of this script could be improved by using multi-threading to run Azure Automation operations in parallel.
* *azurerm_linux_virtual_machine.vm_jumpbox_linux*
  * Terraform azurerm provider has not yet added support for Automatic VM guest patching attributes. See [Support for enable_automatic_updates and patch_mode in azurerm_linux_virtual_machine #13257](https://github.com/hashicorp/terraform-provider-azurerm/issues/13257).

## Next steps

* Move on to the next quick start [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux).
