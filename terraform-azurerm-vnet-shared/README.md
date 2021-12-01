# #AzureQuickStarts - terraform-azurerm-vnet-shared  

## Overview

![vnet-shared-diagram](./vnet-shared-diagram.png)

This quick start implements a virtual network with shared services used by all the quick starts including:

* A [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group)
* A [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview)
* A [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/data-platform#collect-monitoring-data)
* A [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account)
* An [automation account](https://docs.microsoft.com/en-us/azure/automation/automation-intro)
* A [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) for hosting virtual machines used as domain controllers, DNS servers and jump boxes.
* A [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) for secure RDP and SSH access to virtual machines.
* A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) running [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) with a pre-configured domain and DNS server.
* A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) for use as a jumpbox.
* A Linux [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) for use as a jumpbox.

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~30 minutes

## Before you start

Before you start, make sure you have completed the following steps:

* All [Prerequisites](../README.md#Prerequisites) must be completed.
  * The Azure subscription owner must create a service principal with a *Contributor* Azure RBAC role assignment in advance.
  * The *appId* and *password* of the service principal must be known.
  * The quick start user must also have a *Contributor* Azure RBAC role assignment on the Azure subscription.
* Complete the steps in [Configure client environment](../README.md#configure-client-environment).
  * Verify you can start a new Bash terminal session
  * Verify the Azure CLI is installed by running `az --version`
  * Verify PowerShell Core is installed by running `pwsh --version`
  * Verify you have cloned a copy of the GitHub repo with the latest release of the quick start code.

## Getting started

This section describes how to provision this quick start using default settings.

* Open a Bash terminal in your client environment.
* Change the working directory to `~/azurequickstarts/terraform-azurerm-vnet-shared`.
* Run `az logout` and `az account clear` to reset the user credentials used by Azure CLI.
* Run `az login` and sign in using the identity you intend to use for the quick starts.
* Run `az account list -o table` and copy the *Subscription Id* to be used for the quick starts.
* Run `az account set -s 00000000-0000-0000-0000-000000000000` using the *Subscription Id* from the previous step to set the default subscription.
* Run `./bootstrap.sh` using the default settings or your own custom settings.
  * When prompted for *arm_client_id*, use the *appId* for the service principal created by the subscription owner.
  * When prompted for *resource_group_name* use a custom value if there are other quick start users using the same subscription.
  * When prompted for *adminuser*, the default is *bootstrapadmin*.
    * If you use a custom value, avoid using [restricted usernames](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm-).
  * When prompted for *adminpassword*, generate a strong password but be sure to escape any [linux special characters](https://tldp.org/LDP/abs/html/special-chars.html).
* Run `export TF_VAR_arm_client_secret=YourServicePrincipalSecret` replacing *YourServicePrincipalSecret* using the *password* for the service principal created by the subscription owner.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the plan. Monitor the output until you see the message *Apply complete!*.
* Run `terraform state list` to list the resources managed in the configuration.
* Run `terraform output` to view the output variables from the *terraform.tfstate* file.

## Smoke testing

* Explore your newly provisioned resources in the Azure portal.
  * Navigate to *portal.azure.com* > *Automation Accounts* > [My Automation Account] > *Configuration Management* > *State configuration (DSC)*.
    * Refresh the data on the *Nodes* tab and verify that all nodes are compliant.
    * Review the data in the *Configurations* and *Compiled configurations* tabs as well.
* Connect to the Windows Server Jumpbox VM.
  * Navigate to *portal.azure.com* > *Virtual machines* > *jumpwin1*
    * Click *Connect*, select the *Bastion* tab, then click *Use Bastion*
    * For *username* enter the UPN of the domain admin, which by default is *bootstrapadmin@mytestlab.local*.
    * For *password* use the value of the *adminpassword* secret in key vault.
    * Click *Connect*
  * Disable Server Manager
    * Navigate to *Server Manager* > *Manage* > *Server Manager Properties* and enable *Do not start Server Manager automatically at logon*
    * Close Server Manager
  * Configure default browser
    * Navigate to *Settings* > *Apps* > *Default Apps* and set the default browser to *Microsoft Edge*.
  * Inspect the *mytestlab.local* Active Directory domain
    * Navigate to *Start* > *Windows Administrative Tools* > *Active Directory Users and Computers*.
    * Navigate to *mytestlab.local* > *Computers* and verify that *jumpwin1* and *jumplinux1* are listed.
    * Navigate to *mytestlab.local* > *Domain Controllers* and verify that *adds1* is listed.
  * Inspect the *mytestlab.local* DNS zone
    * Navigate to *Start* > *Windows Administrative Tools* > *DNS*
    * Connect to the DNS Server on *adds1*.
    * Click on *adds* in the left pane, then double-click on *Forwarders* in the right pane.
      * Verify that [168.63.129.16](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) is listed. This ensures that the DNS server will forward any DNS queries it cannot resolve to the Azure Recursive DNS resolver.
      * Click *Cancel*.
    * Navigate to *adds1* > *Forward Lookup Zones* > *mytestlab.local* and verify that there are *Host (A)* records for *adds1*, *jumpwin1* and *jumplinux1*.
  * Configure [Visual Studio Code](https://aka.ms/vscode) to do remote development on *jumplinux1*
    * Navigate to *Start* > *Visual Studio Code* > *Visual Studio Code*.
    * Install the [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension.
      * Navigate to *View* > *Extensions*
      * Search for *Remote-SSH*
      * Click *Install*
    * Configure SSH host
      * Navigate to *View* >  *Command Palette...* and enter `Remote-SSH: Add New SSH Host`.
      * When prompted for *Enter SSH Connectino Command* enter `ssh bootstrapadmin@mytestlab.local@jumplinux1`.
      * When prompted for *Select SSH configuration file to update* choose *C:\\Users\\bootstrapadmin\\.ssh\\config*.
    * Connect to SSH host
      * Navigate to *View* >  *Command Palette...* and enter `Remote-SSH: Connect to Host`.
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
        * Verify the Linux distribution and version by running the command `cat /etc/*-release`.
        * Verify the Azure CLI version by running the command `az --version`.
        * Verify the PowerShell version by running the command `pwsh --version`.
        * Verify the Terraform version by running the command `terraform --version`.

## Documentation

This section provides additional information on various aspects of this quick start.

### Bootstrap script

The bootstrap script [bootstrap.sh](./bootstrap.sh) is used to initialize variables and to ensure that all dependencies are in place for the Terraform configuration to be applied. In most real world projects, Terraform configurations will need to reference resources that are not being managed by Terraform because they already exist. It is also sometimes necessary to provision resources in advance to avoid circular dependencies in your Terraform configurations. For this reason, this quick start provisions several resources in advance using [bootstrap.sh](./bootstrap.sh).

[bootstrap.sh](./bootstrap.sh) performs the following operations:

* Generates SSH keys for Linux Jumpbox VM
* Generates a [Mime Multi Part Archive](https://cloudinit.readthedocs.io/en/latest/topics/format.html#mime-multi-part-archive) containing the following files:
  * [configure-vm-jumpbox-linux.yaml](./configure-vm-jumpbox-linux.yaml) is [Cloud Config Data](https://cloudinit.readthedocs.io/en/latest/topics/format.html#cloud-config-data) used to configure the Linux Jumpbox VM.
  * [configure-vm-jumpbox-linux.sh](./configure-vm-jumpbox-linux.sh) is a [User-Data Script](https://cloudinit.readthedocs.io/en/latest/topics/format.html#user-data-script) used to configure the Linux Jumpbox VM.
* Creates a new resource group with the default name *rg-vdc-nonprod-01* used by all the quick starts.
* Creates a storage account with a randomly generated 15-character name like *stxxxxxxxxxxxxx*.
  * The name is limited to 15 characters for compatibility with Active Directory Domain Services.
  * A new *scripts* container is created for quick starts that leverage the Custom Script Extension for [Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) or [Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux).
* Creates a key vault with a randomly generated name like *kv-xxxxxxxxxxxxxxx*.
  * The permission model is set to *Vault access policy*. *Azure role-based access control* is not used to ensure that quick start users only require a *Contributor* Azure RBAC role assignment in order to complete the quick starts.
  * Secrets are created that are used by all quick starts. Note these secrets are static and will need to be manually updated if the values change.
    * *Log analytics workspace primary shared key*: The name of this secret is the same as the id of the log analytics workspace, e.g. *00000000-0000-0000-0000-000000000000*, and the value is the primary shared key which can be used to connect agents to the log analytics workspace.
    * *Storage account access key1*: The name of this secret is the same as the storage account, e.g. *stxxxxxxxxxxxxxxx*, and the value is access key1.
    * *adminpassword*: The password used for default administrator credentials when new quick start resources are provisioned.
    * *adminuser*: The user name used for default administrator credentials when new quick start resources are configured. The default value is *bootstrapadmin*.
    * *bootstrapadmin-ssh-key-private*: The private SSH key used to secure SSH access to Linux VMs created in the quick starts. The value of the *adminpassword* secret is used as the pass phrase.
    * *bootstrapadmin-ssh-key-public*: The public SSH key used to secure SSH access to Linux VMs created in the quick starts.
  * Access policies are created to enable the administration and retrieval of secrets.
    * *AzureQuickStartsSPN* is granted *Get* and *Set* secrets permissions.
    * The quick start user is granted *Get*, *List* and *Set* secrets permissions.
* Creates a *terraform.tfvars* file for generating and applying Terraform plans.

The script is idempotent and can be run multiple times even after the Terraform configuration has been applied.

### Terraform Resources

This section lists the resources included in the Terraform configurations in this quick start.

#### Log Analytics Workspace

The configuration for these resources can be found in [020-loganalytics.tf](./020-loganalytics.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_log_analytics_workspace.log_analytics_workspace_01 (log&#x2011;xxxxxxxxxxxxxxxx&#x2011;01) | See below.
random_id.log_analytics_workspace_01_name | Used to generate a random unique name for *azurerm_log_analytics_workspace.log_analytics_workspace_01*.
azurerm_key_vault_secret.log_analytics_workspace_01_primary_shared_key | Secret used to access *azurerm_log_analytics_workspace.log_analytics_workspace_01*.

The log analytics workspace is for use with services like [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) and [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/security-center-introduction).

#### Azure Automation Account

The configuration for these resources can be found in [030-automation.tf](./030-automation.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_automation_account.automation_account_01 (auto&#x2011;a9866e235174ab6a&#x2011;01) | See below.
random_id.automation_account_01_name | Used to generate a random unique name for *azurerm_automation_account.automation_account_01*

This quick start makes extensive use of [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview) to configure virtual machines using Terraform [Provisioners](https://www.terraform.io/docs/language/resources/provisioners/syntax.html).

* [configure-automation.ps1](./configure-automation.ps1): This script is run by a provisioner in the *azurerm_automation_account.automation_account_01* resource and does the following:
  * Configures [Azure Automation shared resources](https://docs.microsoft.com/en-us/azure/automation/automation-intro#shared-resources) including:
    * [Modules](https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules)
      * Existing modules are updated to the most recent release where possible.
      * Imports new modules including the following:
        * [ActiveDirectoryDsc](https://github.com/dsccommunity/ActiveDirectoryDsc)
        * [NetworkingDsc](https://github.com/dsccommunity/NetworkingDsc)
        * [SqlServerDsc](https://github.com/dsccommunity/SqlServerDsc)
        * [cChoco](https://github.com/chocolatey/cChoco)
    * Bootstraps [Variables](https://docs.microsoft.com/en-us/azure/automation/shared-resources/variables)
    * Bootstraps [Credentials](https://docs.microsoft.com/en-us/azure/automation/shared-resources/credentials)
  * Configures [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview) which is used to configure Windows Server virtual machines used in the quick starts.
    * Imports [DSC Configurations](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-getting-started#create-a-dsc-configuration) used in this and other quick starts.
      * [LabDomainConfig.ps1](./LabDomainConfig.ps1): configure a Windows Server virtual machine as an [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) [Domain Controller](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc786438(v=ws.10)).
      * [JumpBoxConfig.ps1](./JumpBoxConfig.ps1): domain joins a Windows Server virtual machine and configures it as jumpbox.
      * [MssqlVmConfig.ps1](./MssqlVmConfig.ps1): domain joins a Windows Server virtual machine creating using the [SQL Server virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview#payasyougo) offering, configures Windows Firewall rules and configures SQL Server logins.
    * [Compiles DSC Configurations](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-compile) so they can be used later to [Register a VM to be managed by State Configuration](https://docs.microsoft.com/en-us/azure/automation/tutorial-configure-servers-desired-state#register-a-vm-to-be-managed-by-state-configuration).

#### Network resources

The configuration for these resources can be found in [040-network.tf](./040-network.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_virtual_network.vnet_shared_01 (vnet&#x2011;shared&#x2011;01) | By default this virtual network is configured with an address space of `10.1.0.0/16` and is configured with DNS server addresses of 10.1.2.4 (the private ip for *azurerm_windows_virtual_machine.vm_adds*) and [168.63.129.16](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16).
azurerm_subnet.vnet_shared_01_subnets["default"] | The default address prefix for this subnet is 10.1.0.0/24 which includes the private ip address for *azurerm_windows_virtual_machine.vm_jumpbox_win* and *azurerm_linux_virtual_machine.vm_jumpbox_linux*.
azurerm_subnet.vnet_shared_01_subnets["AzureBastionSubnet"] | The default address prefix for this subnet is 10.1.1.0/27 which includes the private ip addresses for *azurerm_bastion_host.bastion_host_01*.
azurerm_subnet.vnet_shared_01_subnets["adds"] | The default address prefix for this subnet is 10.1.2.0/24 which includes the private ip address for *azurerm_windows_virtual_machine.vm_adds*.
azurerm_bastion_host.bastion_host_01 (bst&#x2011;d629fdbde51aca2a&#x2011;1) | Used for secure RDP and SSH access to VMs.
random_id.bastion_host_01_name | Used to generate a random name for *azurerm_bastion_host.bastion_host_01*.
azurerm_public_ip.bastion_host_01 (pip&#x2011;fc0b6ba367b0c212&#x2011;1) | Public ip used by *azurerm_bastion_host.bastion_host_01*.
random_id.public_ip_bastion_host_01_name | Used to generate a random name for *azurerm_public_ip.bastion_host_01*.
azurerm_private_dns_zone.database_windows_net | Creates a [private Azure DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) for using [Azure Private Link for Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview).
azurerm_private_dns_zone.file_core_windows_net | Creates a [private Azure DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) for using [Azure Private Link for Azure Files](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints).
azurerm_private_dns_zone_virtual_network_link.database_windows_net_to_vnet_shared_01 | Links *azurerm_private_dns_zone.database_windows_net* to *azurerm_virtual_network.vnet_shared_01*
azurerm_private_dns_zone_virtual_network_link.file_core_windows_net_to_vnet_shared_01 | Links *azurerm_private_dns_zone.file_core_windows_net* to *azurerm_virtual_network.vnet_shared_01*

#### AD DS Domain Controller VM

The configuration for these resources can be found in [050-vm-adds.tf](./050-vm-adds.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_windows_virtual_machine.vm_adds (adds1) | By default, provisions a [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) virtual machine for use as a domain controller and dns server. See below for more information.
azurerm_network_interface.vm_adds_nic_01 (nic&#x2011;adds1&#x2011;1) | The configured subnet is *azurerm_subnet.vnet_shared_01_subnets["adds"]*.

This Windows Server VM is used as an [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) [Domain Controller](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc786438(v=ws.10)) and a DNS Server running in Active Directory-integrated mode.

* Guest OS: Windows Server 2019 Datacenter Core
* By default the [Patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByPlatform`.
* *admin_username* and *admin_password* are configured using the key vault secrets *adminuser* and *adminpassword*.
* This resource has a dependency on *azurerm_automation_account.automation_account_01*.
* This resource is configured using a [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) that runs [aadsc-register-node.ps1](./aadsc-register-node.ps1) which registers the node with *azurerm_automation_account.automation_account_01* and applies the configuration [LabDomainConfig](./LabDomainConfig.ps1).
  * The `AD-Domain-Services` feature (which includes DNS) is installed.
  * A new *mytestlab.local* domain is configured
    * The domain admin credentials are configured using the *adminusername* and *adminpassword* key vault secrets.
    * The forest functional level is set to `WinThreshhold`
    * A DNS Server is automatically configured
      * Server configuration
        * Forwarder: [168.63.129.16](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16).
          * Note: This ensures that any DNS queries that can't be resolved by the DNS server are forwarded to the Azure recursive resolver as per [Name resolution for resources in Azure virtual networks](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances).
      * *mytestlab.local* DNS forward lookup zone configuration
        * Zone type: Primary / Active Directory-Integrated
        * Dynamic updates: Secure only

#### Windows Server Jumpbox VM

The configuration for these resources can be found in [060-vm-jumpbox-win.tf](./060-vm-jumpbox-win.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_windows_virtual_machine.vm_jumpbox_win (jumpboxwin1) | By default, provisions a [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) virtual machine for use as a jumpbox. See below for more information.
azurerm_network_interface.vm_jumpbox_win_nic_01 (nic&#x2011;jumpwin1&#x2011;1) | The configured subnet is *azurerm_subnet.vnet_shared_01_subnets["default"]*.

This Windows Server VM is used as a jumpbox for development and remote server administration.

* Guest OS: Windows Server 2019 Datacenter.
* By default the [patch orchestration mode](https://docs.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes) is set to `AutomaticByPlatform`.
* *admin_username* and *admin_password* are configured using the key vault secrets *adminuser* and *adminpassword*.
* This resource is configured using a [provisioner](https://www.terraform.io/docs/language/resources/provisioners/syntax.html) that runs [aadsc-register-node.ps1](./aadsc-register-node.ps1) which registers the node with *azurerm_automation_account.automation_account_01* and applies the configuration [JumpBoxConfig](./JumpBoxConfig.ps1).
  * The virtual machine is domain joined.
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

#### Linux Jumpbox VM

The configuration for these resources can be found in [070-vm-jumpbox-linux.tf](./070-vm-jumpbox-linux.tf).

Resource name (ARM) | Notes
--- | ---
azurerm_linux_virtual_machine.vm_jumpbox_linux (jumplinux1) | By default, provisions a [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable) virtual machine for use as a Linux jumpbox virtual machine. See below for more details.
azurerm_network_interface.vm_jumbox_linux_nic_01 | The configured subnet is *azurerm_subnet.vnet_shared_01_subnets["default"]*.
azurerm_key_vault_access_policy.vm_jumpbox_linux_secrets_get | Allows the VM to get secrets from key vault using a system assigned managed identity.

This Linux VM is used as a jumpbox for development and remote administration.

* Guest OS: Ubuntu 20.04 LTS (Focal Fossa)
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

### Terraform output variables

This section lists the output variables defined in the Terraform configurations in this quick start. Some of these may be used for automation in other quick starts.

Output variable | Sample value
--- | ---
aad_tenant_id | "00000000-0000-0000-0000-000000000000"
adds_domain_name | "mytestlab.local"
admin_password_secret | "adminpassword"
admin_username_secret | "adminuser"
arm_client_id | "00000000-0000-0000-0000-000000000000"
automation_account_name | "auto-9a633c2bba9351cc-01"
dns_server | "10.1.2.4"
key_vault_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.KeyVault/vaults/kv-XXXXXXXXXXXXXXX"
key_vault_name | "kv-XXXXXXXXXXXXXXX"
location | "eastus2"
log_analytics_workspace_01_name | "log-XXXXXXXXXXXXXXXX-01"
log_analytics_workspace_01_workspace_id | "00000000-0000-0000-0000-000000000000"
resource_group_name | "rg-vdc-nonprod-01"
storage_account_name | "stXXXXXXXXXXXXXXX"
storage_container_name | "scripts"
subscription_id | "00000000-0000-0000-0000-000000000000"
tags | tomap( { "costcenter" = "10177772" "environment" = "dev" "project" = "#AzureQuickStarts" } )
vnet_shared_01_id | "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01""
vnet_shared_01_name | "vnet-shared-01"

## Known issues

This section documents known issues with this quick start that should be addressed prior to real world usage.

* Identity and Access Management
  * *Authentication*: These quick starts use a service principal to authenticate with Azure which requires a client secret to be shared. This was due to the requirement that the quick start users be limited to a *Contributor* Azure RBAC role assignment which cannot do Azure RBAC role assignments. Real world projects should consider using [managed identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) instead of service principals which eliminates the need to share client secrets.
  * *Credentials*: For simplicity, the quick starts use a single set of credentials when an administrator account is required to provision or configure resources. In real world scenarios these credentials would be different and follow the principal of least privilege for better security.
  * *Active Directory Domain Services*: A preconfigured AD domain controller *azurerm_windows_virtual_machine.vm_adds* is provisioned.
    * *High availability*: The current design uses a single VM for AD DS which is counter to best practices as described in [Deploy AD DS in an Azure virtual network](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/identity/adds-extend-domain) which recommends a pair of VMs in an Availability Set.
    * *Data integrity*: The current design hosts the AD DS domain forest data on the OS Drive which is counter to  best practices as described in [Deploy AD DS in an Azure virtual network](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/identity/adds-extend-domain) which recommends hosting them on a separate data drive with different cache settings.
* Network security controls
  * *azurerm_subnet.vnet_shared_01_subnets["adds"]*: Should be protected by an NSG as per best practices described in described in [Deploy AD DS in an Azure virtual network](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/identity/adds-extend-domain).
* Configuration management
  * *Windows Server*: This quick start uses [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview) for configuring the Windows Server virtual machines, which will be replaced by [Azure Policy guest configuration](https://azure.microsoft.com/en-in/updates/public-preview-apply-settings-inside-machines-using-azure-policys-guest-configuration/) which is currently in public preview. This quick start will be updated to the new implementation when it is generally available.
    * *configure-automation.ps1*: The performance of this script could be improved by using multi-threading to run Azure Automation operations in parallel.
  * *Linux*: This quick start uses [cloud-init](https://cloudinit.readthedocs.io/) for configuring [Ubuntu 20.04 LTS (Focal Fossa)](http://www.releases.ubuntu.com/20.04/) virtual machines.
    * *azurerm_linux_virtual_machine.vm_jumpbox_linux*: ARM tags are currently used to pass some configuration data to cloud-init. This dependency on ARM tags could make the configuration more fragile if users manually manipulate ARM tags or they are overwritten by Azure Policy.
* Patching
  * *azurerm_linux_virtual_machine.vm_jumpbox_linux*
    * The Terraform azurerm provider has not yet added support for Automatic VM guest patching attributes. See [Support for enable_automatic_updates and patch_mode in azurerm_linux_virtual_machine #13257](https://github.com/hashicorp/terraform-provider-azurerm/issues/13257).

## Next steps

* Move on to the next quick start [terraform-azurerm-vnet-app](../terraform-azurerm-vnet-app).
