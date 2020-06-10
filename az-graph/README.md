# Azure quick start: az-graph  

## Overview

This general purpose quick start implements [Azure Resource Graph](https://docs.microsoft.com/en-us/azure/governance/resource-graph/overview) queries used in real world discovery projects for Azure cloud estates. Many of these queries are designed to be imported into data analysis and visualization tools such as Excel or Power BI. Check back from time to time to see if new queries have been added, and contact the author if you would like to contribute. Note there are no Terraform configurations in this quick start.

## Prerequisites

The following prerequisites are required in order to get started.

* [Configure client environment](https://github.com/doherty100/azurequickstarts#configure-client-environment)
* Install the Azure CLI [resource-graph](https://docs.microsoft.com/en-us/azure/governance/resource-graph/first-query-azurecli#add-the-resource-graph-extension) extension (preview)

## Getting started

* Run `./run-queries.sh` to run all of the quick start queries and export results to text files.
  * Note: by default the queries will run against all available subscriptions. Use the -s parameter to limit the scope to a specific subscription.
* Identify a [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group) for provisioning shared resource graph queries, or create a new resource group using [az group create](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-create).
* Run `./create-shared-queries.sh -g RESOURCE_GROUP_NAME` using the resource group identified in the previous step.
* Log into the Azure portal and navigate to the *Directory + subscription* picker in the tool bar. Change the selections based upon the desired scope for resource graph queries.
* Navigate to *All services > Resource Graph Explorer*
* Select the subscription and resource group used previously to provision the shared resource graph queries
  * Navigate to *Open a query > Shared queries > Subscription* and use the picker to choose the subscription where the resource group identified previously
  * Navigate to *Resource group* and choose the resource group identified previously from the picker
  * Note this is only required to locate a shared query in the portal UI
* Click on *resource-count.kql*
* Navigate to the subscription picker in the query window toolbar. Change the selection based upon the desired scope for resource graph queries.
  * Note this is a resource graph specific filter in addition to the main *Directory + subscription* filter for the Azure portal.
* Examine the query syntax, then click *Run query* to view the results
* Click *Download as CSV* in the results window to download the results
* Click the *Charts* tab in the results window and navigate to *Select chart type > Donut chart*
  * Note a *Too many data points* warning may be displayed. If so click *Show top 15 results*
* Examine the donut chart for insights
* Click *Pin to dashboard* and pin the query to a new or existing Azure portal dashboard
* Navigate to the dashboard identified in the previous step to view the pinned resource graph query results chart

## Query index

This section enumerates the resource graph queries included in the quick start. Queries are grouped by usage including [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/), [IaaS](https://azure.microsoft.com/en-us/overview/what-is-iaas/) and *General* categories. *Import optimized* indicates that the query uses naming conventions and includes keys that are useful for importing into data analysis and visualization tools. Note the IaaS queries that are import optimized can be joined using keys. For example, you can join a virtual machine with it's related nics and disks. This is very useful for configuration management projects.

Name | Description | Group | Import optimized
--- | --- | --- | ---
disk-details.kql | List disks with details | IaaS | Yes
nic-details.kql | List nics with details | IaaS | Yes
pip-details.kql | List public ips with details | General | Yes
resource-count.kql | Count of resources by type | General | No
storage-details.kql | List storage accounts with details | PaaS | Yes
storage-summary.kql | Summarize storage accounts by sku | PaaS | No
subnet-details.kql | List subnets with details | IaaS | Yes
vm-details.kql | List virtual machines with details | IaaS | Yes
vm-summary.kql | Summarize virtual machines by size | IaaS | No
vnet-details.kql |  List virtual networks with details | IaaS | Yes
