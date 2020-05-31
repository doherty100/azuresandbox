# Azure quick starts by [Roger Doherty](https://www.linkedin.com/in/roger-doherty-805635b/)

## Overview

This repository contains a collection of inter-dependent [cloud computing](https://azure.microsoft.com/en-us/overview/what-is-cloud-computing) quick starts for implementing common [Microsoft Azure](https://azure.microsoft.com/en-us/overview/what-is-azure/) services on a single [subscription](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#subscription). Collectively these quick starts implement a basic [hub-spoke networking topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) using automation implemented using popular open source tools that are supported on Windows, macOS and Linux including:

* [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) for scripting.
* [git](https://git-scm.com/) for source control.
* [jq](https://stedolan.github.io/jq) for processing JSON inputs in Bash scripts.
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest) is a command line interface for Azure.
* [Terraform](https://www.terraform.io/intro/index.html#what-is-terraform-) for [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC).

## Quick start index

The quick starts feature a modular design and can be deployed as a whole or incrementally depending upon requirements, and are intended to demonstrate sound architectural best practices including security and operational efficiency. Each is listed here in suggested order of deployment.

* [terraform-azurerm-vnet-hub](./terraform-azurerm-vnet-hub/)
  * Shared [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group)  
  * Shared hub [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet)  
  * Dedicated [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview)  
  * Shared [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account)  
  * Shared [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview)  
  * Shared [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment)  
  * Shared [image gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries)
* [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/)
  * Dedicated spoke virtual network  
  * Dedicated bastion  
  * Pre-configured bidirectional [virtual network peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) with [terraform-azurerm-vnet-hub](./terraform-azurerm-vnet-hub/README.md)  
* [terraform-azurerm-vm-windows](./terraform-azurerm-vm-windows/)
  * Windows Server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm)
* [terraform-azurerm-vwan](./terraform-azurerm-vwan/)
  * Shared [virtual wan](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources)
  * Shared [virtual wan hub](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) with pre-configured [hub virtual network connections](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about#resources) with [terraform-azurerm-vnet-hub](./terraform-azurerm-vnet-hub/README.md) and [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/README.md)  

## Prerequisites

The following prerequisites are required in order to get started.

* Identify an existing subscription or create a new subscription. See [Azure Offer Details](https://azure.microsoft.com/en-us/support/legal/offer-details/) for more information.  
* Identify the [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-whatis) (AAD) tenant associated with the subscription, or create a new AAD tenant using [Quickstart: Set up a tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-create-new-tenant) and associate the the subscription to it. See [Associate or add an Azure subscription to your Azure Active Directory tenant](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory) for more information.  
* Identify an existing security principal (user or group account) in the AAD tenant to be used to deploy the quick starts, or create a new security principal. See [Manage app and resource access using Azure Active Directory groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-manage-groups) for more information.  
* Verify the security principal is a member of the Contributor [Azure built-in role](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles). See [Add or remove Azure role assignments using the Azure portal](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal) for more information.

## Getting started

Familiarity with the following topics will be helpful when working with the quick starts:

* Familiarize yourself with Terraform [Input Variables](https://www.terraform.io/docs/configuration/variables.html)  
* Familiarize yourself with Terraform [Output Values](https://www.terraform.io/docs/configuration/outputs.html) also referred to as *Output Variables*
* Familiarize yourself with [Recommended naming and tagging conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) and [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)

### Configure client environment

This section describes the various client environments that can be used to interactively deploy the quick starts.

#### Cloud shell

Azure [cloud shell](https://aka.ms/cloudshell) is a free pre-configured cloud hosted container with a full complement of [tools](https://docs.microsoft.com/en-us/azure/cloud-shell/features#tools) needed to deploy the quick starts. This option will be preferred for users who do not wish to install any software and don't mind a web based command line user experience. Review the following content to get started:

* [Bash in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart)
* [Persist files in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage)
* [Using the Azure Cloud Shell editor](https://docs.microsoft.com/en-us/azure/cloud-shell/using-cloud-shell-editor)

Note that cloud shell containers are ephemeral. Anything not saved in `~/clouddrive` will not be retained when your cloud shell session ends. Also, cloud shell sessions expire. This can interrupt a long running process.

#### Windows

Windows 10 users can deploy the quick starts using [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) which supports a [variety of Linux distributions](https://docs.microsoft.com/en-us/windows/wsl/install-win10#install-your-linux-distribution-of-choice). Here is a sample configuration preferred by the author:

* [Ubuntu 18.04.4 LTS](https://www.microsoft.com/store/productId/9N9TNGVNDL3Q)
* [Install Azure CLI with apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
* [Terraform | Linux | 64-bit](https://www.terraform.io/downloads.html).
  * Installation helper script: [terraforminstall.sh](./terraform-general/terraforminstall.sh)
* [VS Code for Windows](https://aka.ms/vscode) with the following extensions:
  * [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
  * [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)

#### Linux / macOS

Linux and macOS users can deploy the quick starts natively by installing the following tools:

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest)
  * [Install Azure CLI on macOS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
  * Install Azure CLI on Linux
    * Debian or Ubuntu: [Install Azure CLI with apt](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
    * RHEL, Fedora or CentOS: [Install Azure CLI with yum](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest)
    * openSUSE or SLE: [Install Azure CLI with zypper](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-zypper?view=azure-cli-latest)
    * [Install Azure CLI on Linux manually](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest)
* [Terraform](https://www.terraform.io/downloads.html).
  * Installation helper script: [terraforminstall.sh](./terraform-general/terraforminstall.sh)

Note the Bash scripts used in the quick starts were developed and tested using `GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)` and have not been tested on other popular shells like [zsh](https://www.zsh.org/).

### Next steps

Now that the client environment has been configured, here's how to start working with the quick starts.

* Open a new command shell in the client environment.
* Run `git clone https://github.com/doherty100/azurequickstarts` to clone this repository into a new directory in the client environment.
* Deploy the quick starts in the following order:
  * Start by deploying the [terraform-azurerm-vnet-hub](./terraform-azurerm-vnet-hub/) quick start which establishes a shared hub virtual network and shared services.
  * Next, deploy the [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-spoke/) quick start which establishes a dedicated spoke virtual network.
  * Proceed by deploying the [terraform-azurerm-vm-windows](./terraform-azurerm-vm-windows/) quick start which implements a dedicated Windows Server virtual machine in the dedicated spoke virtual network.
  * Finish by deploying the [terraform-azurerm-vwan](./terraform-azurerm-vwan/) quick start which connects the shared hub virtual network and the dedicated spoke virtual network to remote users or a private network.
