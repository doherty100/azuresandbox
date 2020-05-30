# Azure quick starts by [Roger Doherty](https://www.linkedin.com/in/roger-doherty-805635b/)

\[ [azurequickstarts](./) \]

## Overview

This repository contains a collection of inter-dependent [cloud computing](https://azure.microsoft.com/en-us/overview/what-is-cloud-computing) quick starts for implementing common [Microsoft Azure](https://azure.microsoft.com/en-us/overview/what-is-azure/) services on a single [subscription](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#subscription). Collectively these quick starts implement a basic [hub-spoke networking topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) using automation implemented using popular Linux open source tools that are supported on Windows and macOS including:

* [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) for scripting.
* [jq](https://stedolan.github.io/jq) for processing JSON inputs in Bash scripts.
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest) is a command line interface for Azure.
* [Hashicorp Terraform](https://www.terraform.io/intro/index.html#what-is-terraform-) for [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC).

## Quick start index

The quick starts feature a modular design and can be deployed as a whole or incrementally depending upon requirements. Each is listed here in suggested order of deployment.

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

* Familiarize yourself with Terraform [Input Variables](https://www.terraform.io/docs/configuration/variables.html)  
* Familiarize yourself with Terraform [Output Values](https://www.terraform.io/docs/configuration/outputs.html) also referred to as *Output Variables*
* Familiarize yourself with [Recommended naming and tagging conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) and [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
* Deploy the quick starts in the following order:
  * Start by deploying the [terraform-azurerm-vnet-hub](./terraform-azurerm-vnet-hub/) quick start which establishes a shared hub virtual network and shared services.
  * Next, deploy the [terraform-azurerm-vnet-spoke](./terraform-azurerm-vnet-hub/) quick start which establishes a dedicated spoke virtual network.
  * Proceed by deploying the [terraform-azurerm-vm-windows](./terraform-azurerm-vm-windows/) quick start which implements a dedicated Windows Server virtual machine in the dedicated spoke virtual network.
  * Finish by deploying the [terraform-azurerm-vwan](./terraform-azurerm-vwan/) quick start which connects the shared hub virtual network and the dedicated spoke virtual network to remote users or a private network.
