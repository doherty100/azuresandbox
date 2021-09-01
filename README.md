# #AzureQuickStarts

## Overview

This repository contains a collection of inter-dependent [cloud computing](https://azure.microsoft.com/en-us/overview/what-is-cloud-computing) quick starts for implementing common [Microsoft Azure](https://azure.microsoft.com/en-us/overview/what-is-azure/) services on a single [subscription](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#subscription). Collectively these quick starts provide a flexible lab environment useful for experimenting with various Azure services and capabilities. The quick starts are implemented using popular open source automation tools that are supported on Windows, macOS and Linux including:

* [git](https://git-scm.com/) for source control.
* [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) for scripting.
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest) is a command line interface for Azure.
* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1)
  * [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-71?view=powershell-7.1) for use with [Azure Automation State Configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-intro#azure-automation-state-configuration)
  * [PowerShell 5.1](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-5.1) for Windows Server configuration.
* [Terraform](https://www.terraform.io/intro/index.html#what-is-terraform-) v1.0.5 for [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC).
  * [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) (azuerrm) v2.74.0
  * [Random Provider](https://registry.terraform.io/providers/hashicorp/random/latest/docs) (random) v3.1.0

This repo was created by [Roger Doherty](https://www.linkedin.com/in/roger-doherty-805635b/).

## Quick start index

\#AzureQuickStarts features a modular design and can be deployed as a whole or incrementally depending upon your requirements. It is  intended to accelerate cloud projects using best practices where feasible in a test lab environment. Each is listed here in suggested order of deployment.

* [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared/)
  * A [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group) for provisioning Azure resources
  * A [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) for storing and retrieving shared secrets
  * A [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account) for storing and retrieving data
  * A [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/data-platform#collect-monitoring-data) for storing and querying metrics and logs
  * An [automation account](https://docs.microsoft.com/en-us/azure/automation/automation-intro) for [Azure automation state configuration (DSC)](https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview)
  * A [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) for hosting virtual machines used as domain controllers, DNS servers and jump boxes.
  * A [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) for secure RDP and SSH access to virtual machines.
  * A Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) running [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) with a pre-configured domain and DNS server.
* [terraform-azurerm-vm-windows](./terraform-azurerm-vm-windows/)
  * [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/) offering
* [terraform-azurerm-vm-linux](./terraform-azurerm-vm-linux/)
  * [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) jump box [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [Linux virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/) offering
* [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/)
  * Dedicated spoke virtual network  
  * Pre-configured bidirectional [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) with [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared/)  
* [terraform-azurerm-vm-sql](./terraform-azurerm-vm-sql/)
  * [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) database server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) based on the [SQL Server virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-server-on-azure-vm-iaas-what-is-overview#payasyougo) offering
* [terraform-azurerm-sql](./terraform-azurerm-sql/)
  * [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) database using [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview).
* [terraform-azurerm-vwan](./terraform-azurerm-vwan/)
  * Shared [virtual wan](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources)
  * Shared [virtual wan hub](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) with pre-configured [hub virtual network connections](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) with [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared/) and [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/)
* Miscellaneous quick starts
  * [az-graph](./az-graph/)
    * Common [Azure Resource Graph](https://docs.microsoft.com/en-us/azure/governance/resource-graph/overview) queries used for real world cloud estate discovery projects
    * Utility script for executing resource graph queries and exporting results
    * Utility script for provisioning shared resource graph queries

## Prerequisites

The following prerequisites are required in order to get started. Note that once these prerequisite are in place, a [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) Azure RBAC role assignment is sufficient to use the quick starts.

* Identify the [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-whatis) (AAD) tenant to be used for identity and access management, or create a new AAD tenant using [Quickstart: Set up a tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-create-new-tenant).
* Identify a single Azure [subscription](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#subscription) or create a new Azure subscription. See [Azure Offer Details](https://azure.microsoft.com/en-us/support/legal/offer-details/) and [Associate or add an Azure subscription to your Azure Active Directory tenant](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory) for more information.
* Identify the owner of the Azure subscription to be used for \#AzureQuickStarts. This user should have an [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) Azure RBAC role assignment on the subscription. See [Steps to assign an Azure role](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-steps) for more information.
* Ask the subscription owner to create a [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) Azure RBAC role assignment for each quick start user. See [Steps to assign an Azure role](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-steps) for more information.
* Verify the subscription owner has privileges to create a Service Principle name on the AAD tenant. See [Check Azure AD permissions](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#check-azure-ad-permissions) for more information.
* Ask the subscription owner to [Create a service principle](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) (SPN) for quick start users using the Azure CLI command `az ad sp create-for-rbac -n AzureQuickStartsSPN --role Contributor` using the [Quickstart for Bash in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart). Securely share the output with quick start users, including *appId* and *password*.
* Aks the subscription owner to enable automatic guest VM patching. See [Requirements for enabling automatic VM guest patching](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/automatic-vm-guest-patching) for more information.
* Some organizations may institute [Azure policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview) which may cause some quick start deployments to fail. This can be addressed by using custom settings which pass the policy checks, or by disabling the policies on the Azure subscription being used for the quick starts.
* Some Azure subscriptions may have low quota limits for specific Azure resources which may cause quick start deployments to fail. See [Resolve errors for resource quotas](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/error-resource-quota) for more information. Consult the following table to determine if quota increases are required to deploy the quick starts using default settings:

Resource |  Quota required per deployment | Command
--- | :-: | ---
Public IP Addresses | ~2 | *az network list-usages*
Standard BS Family vCPUs | ~5 | *az vm list-usage*
Standard Sku Public IP Addresses | ~2 | *az network list-usages*
Static Public IP Addresses  | ~2 | *az network list-usages*

*Note:* This list is not comprehensive. Quotas vary by Azure subscription offer type and environment. More than one quota may need to be increased for a single resource type, such as [public ip addresses](https://docs.microsoft.com/en-us/azure/virtual-network/public-ip-addresses).

## Getting started

Before you begin, familiarity with the following topics will be helpful when working with \#AzureQuickStarts:

* Familiarize yourself with Terraform [Input Variables](https://www.terraform.io/docs/configuration/variables.html)  
* Familiarize yourself with Terraform [Output Values](https://www.terraform.io/docs/configuration/outputs.html) also referred to as *Output Variables*
* See [Authenticating to Azure using a Service Principal and a Client Secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) to understand the type of authentication used by Terraform in \#AzureQuickStarts
* Familiarize yourself with [Recommended naming and tagging conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
* Familiarize yourself with [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)

### Configure client environment

---

Each quick start user must select and configure a client environment in advance. A variety of options are available and are detailed in this section.

#### Cloud shell

Azure [cloud shell](https://aka.ms/cloudshell) is a free pre-configured cloud hosted container with a full complement of [tools](https://docs.microsoft.com/en-us/azure/cloud-shell/features#tools) needed to use \#AzureQuickStarts. This option will be preferred for users who do not wish to install any software and don't mind a web based command line user experience. Review the following content to get started:

* [Bash in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart)
* [Persist files in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage)
* [Using the Azure Cloud Shell editor](https://docs.microsoft.com/en-us/azure/cloud-shell/using-cloud-shell-editor)

*Warning:* Cloud shell containers are ephemeral. Anything not saved in `~/clouddrive` will not be retained when your cloud shell session ends. Also, cloud shell sessions expire. This can interrupt a long running process.

#### Windows 10 with WSL

Windows 10 users can use [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) which supports a [variety of Linux distributions](https://docs.microsoft.com/en-us/windows/wsl/install-win10#install-your-linux-distribution-of-choice). Here is a sample configuration preferred by the author:

* Windows 10 prerequisites
  * [Windows Subsystem for Linux Installation Guide for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
  * [Ubuntu 20.04 LTS (Focal Fossa)](https://www.microsoft.com/store/productId/9N6SVWS3RX71)
  * [Visual Studio Code on Windows | Installation](https://code.visualstudio.com/docs/setup/windows))
* WSL prerequisites
  * [Install the Azure CLI on Linux | apt (Ubuntu, Debian)](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
  * [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
    * Refer to the *Linux* tab then choose the *Ubuntu/Debian* tab.
    * Note: Skip the [Quick start tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli#quick-start-tutorial).
  * [Installing PowerShell on Linux | Ubuntu 20.04](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004)
    * After installing, run [configure-powershell.ps1](./configure-powershell.ps1)
  * VS Code extensions for WSL
    * [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
    * [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)

#### Linux / macOS

Linux and macOS users can deploy the quick starts natively by installing the following tools:

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest)
  * Debian or Ubuntu: [Install Azure CLI with apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
  * RHEL, Fedora or CentOS: [Install Azure CLI with yum](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest)
  * openSUSE or SLES: [Install Azure CLI with zypper](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-zypper?view=azure-cli-latest)
  * [Install Azure CLI on macOS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
  * [Install Azure CLI on Linux manually](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest)
* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
  * Refer to the *Linux* tab then choose the corresponding tab for your distro if installing on Linux.
  * Refer to the *Homebrew on OS X* if installing on macOS.
  * Note: Skip the [Quick start tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli#quick-start-tutorial).
* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1)
  * [Installing PowerShell on Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1)
  * [Installing PowerShell on macOS](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7.1)
  * After installing, run [configure-powershell.ps1](./configure-powershell.ps1)
* [VS Code](https://aka.ms/vscode)
  * [Linux](https://code.visualstudio.com/docs/setup/linux)
  * [macOS](https://code.visualstudio.com/docs/setup/mac)
  * After installing, add the following extensions:
    * [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)

Note the Bash scripts used in the quick starts were developed and tested using *GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)* and have not been tested on other popular shells like [zsh](https://www.zsh.org/).

## Next steps

Now that the client environment has been configured, here's how to clone a copy of this repo and start working with the latest release of code.

```lang-bash
git clone https://github.com/doherty100/azurequickstarts
cd azurequickstarts
latestTag=$(git describe --tags $(git rev-list --tags --max-count=1))
git checkout $latestTag
```

### Perform default quick start deployment

---

For the first deployment, the author recommends using defaults, which is ideal for speed, learning and testing. IP address ranges are expressed using [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation).

#### Default IP address ranges

The quick starts use default IP address ranges for networking components. These ranges are artificially large and contiguous for simplicity, and customized IP address ranges can be much smaller. A suggested minimum is provided to assist in making the conversion. It's a good idea to start small. Additional IP address ranges can be added to the networking configuration in the future if you need them, but you can't modify an existing IP address range to make it smaller.

Address range | CIDR | First | Last | IP address count | Suggested minimum range
--- |--- | --- | --- | --: | ---
Reserved for private network | 10.0.0.0/16 | 10.0.0.0 | 10.0.255.255 | 65,536 | N/A
Default quick start aggregate | 10.1.0.0/13 | 10.1.0.0 | 10.7.255.255 | 524,288 | /22 (1024 IP addresses)
Shared services virtual network | 10.1.0.0/16 | 10.1.0.0 | 10.1.255.255 | 65,536 | /24 (256 IP addresses)
Spoke virtual network | 10.2.0.0/16 | 10.2.0.0 | 10.2.255.255 | 65,536 | /24 (256 IP addresses)
Virtual wan hub | 10.3.0.0/16 | 10.3.0.0 | 10.3.255.255 | 65,536 | /24 (256 IP addresses)
P2S client VPN connections | 10.4.0.0/16 | 10.4.0.0 | 10.4.255.255 | 65,536 | /24 (256 IP addresses)
Reserved for future use | 10.5.0.0/16 | 10.5.0.0 | 10.5.255.255 | 65,536 | N/A
Reserved for future use | 10.6.0.0/15 | 10.6.0.0 | 10.7.255.255 | 131,072 | N/A

##### Default subnet IP address prefixes

This section documents the default subnet IP address prefixes used in the quick starts. Subnets enable you to segment the virtual network into one or more sub-networks and allocate a portion of the virtual network's address space to each subnet. You can then connect network resources to a specific subnet, and secure them using [network security qroups](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview).

Virtual network | Subnet | IP address prefix | First | Last | IP address count
--- | --- | --- | --- | --- | --:
Shared services | snet-default-01 | 10.1.0.0/24 | 10.1.0.0 | 10.1.0.255 | 256
Shared services | AzureBastionSubnet | 10.1.1.0/27 | 10.1.1.0 | 10.1.1.31 | 32
Shared services | Reserved for future use | 10.1.1.32/27 | 10.1.1.32 | 10.1.1.63 | 32
Shared services | Reserved for future use | 10.1.1.64/26 | 10.1.1.64 | 10.1.1.127 | 64
Shared services | Reserved for future use | 10.1.1.128/25 | 10.1.1.128 | 10.1.1.255 | 128
Shared services | snet-adds-01 | 10.1.2.0/24 | 10.1.2.0 | 10.1.2.255 | 256
Shared services | Reserved for future use | 10.1.3.0/24 | 10.1.3.0 | 10.1.3.255 | 256
Shared services | Reserved for future use | 10.1.4.0/22 | 10.1.4.0 | 10.1.7.255 | 1,024
Shared services | Reserved for future use | 10.1.8.0/21 | 10.1.8.0 | 10.1.15.255 | 2,048
Shared services | Reserved for future use | 10.1.16.0/20 | 10.1.16.0 | 10.1.31.255 | 4,096
Shared services | Reserved for future use | 10.1.32.0/19 | 10.1.32.0 | 10.1.63.255 | 8,192
Shared services | Reserved for future use | 10.1.64.0/18 | 10.1.64.0 | 10.1.127.255 | 16,384
Shared services | Reserved for future use | 10.1.128.0/17 | 10.1.128.0 | 10.1.255.255 | 32,768
Spoke | snet-default-02 | 10.2.0.0/24 | 10.2.0.0 | 10.2.0.255 | 256
Spoke | snet-db-01 | 10.2.1.0/27 | 10.2.1.0 | 10.2.1.31 | 32
Spoke | snet-app-01 | 10.2.1.32/27 | 10.2.1.32 | 10.2.1.63 | 32
Spoke | snet-storage-private-endpoints-02 | 10.2.1.64/27 | 10.2.1.64 | 10.2.1.95 | 32
Spoke | Reserved for future use | 10.2.1.96/27 | 10.2.1.96 | 10.2.1.127 | 32
Spoke | Reserved for future use | 10.2.1.128/25 | 10.2.1.128 | 10.2.1.255 | 128
Spoke | Reserved for future use | 10.2.2.0/23 | 10.2.2.0 | 10.2.3.255 | 512
Spoke | Reserved for future use | 10.2.4.0/22 | 10.2.4.0 | 10.2.7.255 | 1,024
Spoke | Reserved for future use | 10.2.8.0/21 | 10.2.8.0 | 10.2.15.255 | 2,048
Spoke | Reserved for future use | 10.2.16.0/20 | 10.2.16.0 | 10.2.31.255 | 4,096
Spoke | Reserved for future use | 10.2.32.0/19 | 10.2.32.0 | 10.2.63.255 | 8,192
Spoke | Reserved for future use | 10.2.64.0/18 | 10.2.64.0 | 10.2.127.255 | 16,384
Spoke | Reserved for future use | 10.2.128.0/17 | 10.2.128.0 | 10.2.255.255 | 32,768

#### Apply quick start configurations

Apply the quick starts in the following order:

1. [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared/) implements a virtual network with shared services used by all the quick starts.
1. [terraform-azurerm-vm-windows](./terraform-azurerm-vm-windows/) implements a dedicated Windows Server virtual machine connected to the shared services virtual network.
1. [terraform-azurerm-vm-linux](./terraform-azurerm-vm-linux/) implements a dedicated Linux virtual machine connected to the shared services virtual network.
1. [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/) establishes a dedicated spoke virtual network.
1. [terraform-azurerm-vm-sql](./terraform-azurerm-vm-sql/) implements a pre-configured environment for running benchmarks like [HammerDB](https://www.hammerdb.com/) and testing web applications using an [IaaS](https://azure.microsoft.com/en-us/overview/what-is-azure/iaas/) approach.
1. [terraform-azurerm-sql](./terraform-azurerm-sql/) implements an Azure SQL Database for running benchmarks like [HammerDB](https://www.hammerdb.com/) and testing web applications using a [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) approach.
1. [terraform-azurerm-vwan](./terraform-azurerm-vwan/) connects the shared services virtual network and the dedicated spoke virtual network to remote users or a private network.

#### Destroy quick start configurations

While a default quick start deployment is fine for testing, it may not work with an organization's private network. The default deployment should be destroyed first before doing a custom deployment. This is accomplished by running `terraform destroy` on each quick start in the reverse order in which it was deployed:

1. [terraform-azurerm-vwan](./terraform-azurerm-vwan/)
1. [terraform-azurerm-sql](./terraform-azurerm-sql/)
1. [terraform-azurerm-vm-sql](./terraform-azurerm-vm-sql/)
1. [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/)
1. [terraform-azurerm-vm-linux](./terraform-azurerm-vm-linux/)
1. [terraform-azurerm-vm-windows](./terraform-azurerm-vm-windows/)
1. [terraform-azurerm-vnet-shared](./terraform-azurerm-vnet-shared/). Note: Resources provisioned by `bootstrap.sh` must be deleted manually.

Alternatively, for speed, simply run `az group delete -g rg-vdc-nonprod-01`.

### Perform custom quick start deployment

---

A custom deployment will likely be required to connect the quick starts to an organization's private network. This section provides guidance on how to customize the quick starts.

#### Document private network IP address ranges (sample)

Use this section to document one or more private network IP address ranges by consulting a network professional. This is required if you want to establish a [hybrid connection](https://docs.microsoft.com/en-us/azure/architecture/solution-ideas/articles/hybrid-connectivity) between an organization's private network and the quick starts. The sample includes two IP address ranges used in a private network. The [CIDR to IPv4 Conversion](https://ipaddressguide.com/cidr) tool may be useful for completing this section.

IP address range | CIDR | First | Last | IP address count
--- | --- | --- | --- | --:
Primary range | 10.0.0.0/8 | 10.0.0.0 | 10.255.255.255 | 16,777,216
Secondary range | 162.44.0.0/16 | 162.44.0.0 | 162.44.255.255 | 65,536

A blank table is provided here for convenience. Make a copy of this table and change the *TBD* values to your custom values.

IP address range | CIDR | First | Last | IP address count
--- | --- | --- | --- | --:
Primary range | TBD | TBD | TBD | TBD
Secondary range | TBD | TBD | TBD | TBD

#### Customize IP address ranges (sample)

Use this section to customize the default IP address ranges used by the quick starts to support routing on an organization's private network. The aggregate range should be determined by consulting a network professional, and will likely be allocated using a range that falls within the private network IP address ranges discussed previously, and the rest of the IP address ranges must be contained within it. The [CIDR to IPv4 Conversion](https://ipaddressguide.com/cidr) tool may be useful for completing this section. Note this sample uses the suggested minimum address ranges from the default IP address ranges described previously.

IP address range | CIDR | First | Last | IP address count
--- | --- | --- | --- | --:
Aggregate range | 10.73.8.0/22 | 10.73.8.0 | 10.73.11.255 | 1,024
Shared services virtual network | 10.73.8.0/24  | 10.73.8.0 | 10.73.8.255 | 256
Spoke virtual network | 10.73.9.0/24 | 10.73.9.0 | 10.73.9.255 | 256
Virtual wan hub | 10.73.10.0/24 | 10.73.10.0 | 10.73.10.255 | 256
P2S client VPN connections | 10.73.11.0/24 | 10.73.11.0 | 10.73.11.255 | 256

A blank table is provided here for convenience. Make a copy of this table and change the *TBD* values to your custom values.

IP address range | CIDR | First | Last | IP address count
--- | --- | --- | --- | --:
Aggregate range | TBD | TBD | TBD | TBD
Shared services virtual network | TBD  | TBD | TBD | TBD
Spoke virtual network | TBD | TBD | TBD | TBD
Virtual wan hub | TBD | TBD | TBD | TBD
P2S client VPN connections | TBD | TBD | TBD | TBD

##### Customize subnet IP address prefixes (sample)

Use this section to customize the default subnet IP address prefixes used by the quick starts to support routing on an organization's private network. Make a copy of this table and change these sample values to custom values. Each address prefix must fall within the virtual network IP address ranges discussed previously. The [CIDR to IPv4 Conversion](https://ipaddressguide.com/cidr) tool may be useful for completing this section.

Virtual network | Subnet | IP address prefix | First | Last | IP address count
--- | --- | --- | --- | --- | --:
Shared services | snet-default-01 | 10.73.8.0/25 | 10.73.8.0 | 10.73.8.127 | 128
Shared services | AzureBastionSubnet | 10.73.8.128/27 | 10.73.8.128 | 10.73.8.159 | 32
Shared services | snet-adds-01 | 10.73.8.160/27 | 10.73.8.160 | 10.73.8.191 | 32
Shared services | Reserved for future use | 10.73.8.192/27 | 10.73.8.192 | 10.73.8.223 | 32
Shared services | Reserved for future use | 10.73.8.224/27 | 10.73.8.224 | 10.73.8.255 | 32
Spoke | snet-default-02 | 10.73.9.0/25 | 10.73.9.0 | 10.73.9.127 | 128
Spoke | snet-db-01 | 10.73.9.128/27 | 10.73.9.128 | 10.73.9.159 | 32
Spoke | snet-app-01 | 10.73.9.160/27 | 10.73.9.160 | 10.73.9.191 | 32
Spoke | snet-storage-private-endpoints-02 | 10.73.9.192/27 | 10.73.9.192 | 10.73.9.223 | 32
Spoke | Reserved for future use | 10.73.9.224/27 | 10.73.9.224 | 10.73.9.255 | 32

It is recommended to reserve space for future subnets. A blank table is provided here for convenience. Make a copy of this table and change the *TBD* values to your custom values.

Virtual network | Subnet | IP address prefix | First | Last | IP address count
--- | --- | --- | --- | --- | --:
Shared services | snet-default-01 | TBD | TBD | TBD | TBD
Shared services | AzureBastionSubnet | TBD | TBD | TBD | TBD
Shared services | snet-storage-private-endpoints-01 | TBD | TBD | TBD | TBD
Shared services | Reserved for future use | TBD | TBD | TBD | TBD
Spoke | snet-default-02 | TBD | TBD | TBD | TBD
Spoke | AzureBastionSubnet | TBD | TBD | TBD | TBD
Spoke | snet-db-01 | TBD | TBD | TBD | TBD
Spoke | snet-app-01 | TBD | TBD | TBD | TBD
Spoke | snet-storage-private-endpoints-02 | TBD | TBD | TBD | TBD
