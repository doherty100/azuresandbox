# Azure quickstarts configuration: terraform-azurerm-vnet-hub  

\[ [azurequickstarts](../README.md) \] > \[ [terraform-azurerm-vnet-hub](./README.md) \]

## Overview

This quickstart implements the hub portion of a basic hub-spoke networking topology with shared services. It is the primary building block upon which all the other quickstarts are built.

Activity | Estimated time required
--- | ---
Pre-configuration (default) | 10 minutes
Pre-configuration (custom) | 1 hour
Provisioning (average) | 7 minutes
Post-configuration | 10 minutes
De-provisioning (average) | 17 minutes

## Getting started using default settings

* Make your own copy of *run-gen-tfvarsfile.sh* to ensure custom settings don't get clobbered in the future, for example:
 `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private2.sh`
* Edit your copy of *run-gen-tfvarsfile.sh* and update the following parameters:  
  * -o: Change this to the objectId of your user account in AAD. This can \be determined by running:
  `az ad user show --id myuser@consoso.com | jq -r .objectId`  
  * -d: Change this to the AAD tenantId associated with your subscription which can be determined by running:
   `az account show | jq -r .tenantId`
* Save your changes.
* Generate a new *terraform.tfvars* file by running your copy of *run-gen-tfvarsfile.sh*, for example:
`./run-gen-tfvarsfile-private.sh`  
* Run `terraform init` and note the version of the azurerm provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform apply` to apply the configuration.
* Run `terraform output` to view the output variables form the *terraform.tfstate* file.
* Explore your newly previsioned resources in the Azure portal.
* Run `terraform destroy` to destroy the configuration.
* Re-apply the configuration and move on to [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke/README.md).

## Getting started using custom settings

## Resource index

This section provides an index of the resources included in this quickstart.

### Resource group

---

Shared [resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group) used by all quickstart configurations.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
resource_group_name | Input | string | All quickstarts | rg-vdc-nonprod-001
location | Input | string | All quickstarts | eastus
tags | Input | map | This quickstart | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
resource_group_01_id | Output | string | This quickstart | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001

### Virtual network

---

Shared hub [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet) used by all quickstart configurations.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_name | Input | string | This quickstart | vnet-hub-001
address_space | Input | string | This quickstart | 10.1.0.0/16
tags | Input  | map | This quickstart | See previous sample for shared resource group
vnet_hub_id | output | string | This quickstart | TBD

#### Subnets

Shared hub virtual network [subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets). Note the following naming conventions used in the sample values are significant:

* A subnet named *snet-storage-private-endpoints-001* required for use in the shared file share resource described later.  
* A subnet named *snet-bastion-001* is reserved for use in the bastion resource described later.  
* Subnets starting with the characters *snet-storage-private-endpoints* are automatically configured with [enforce_private_link_endpoint_network_policies](https://www.terraform.io/docs/providers/azurerm/r/subnet.html#enforce_private_link_endpoint_network_policies) set to *true* and are required for configuring the shared file share resource described later.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
subnets | Input | map | This quickstart | { snet-default-001 = \"10.1.0.0/24\", snet-bastion-001 = \"10.1.1.0/27\", snet-storage-private-endpoints-001 = \"10.1.2.0/24\" }
vnet_hub_subnets | Output | string (json) | This quickstart | TBD

### Storage account

---

Shared general-purpose v2 standard [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account) with an automatically generated random name following the grep format "st\[a-z0-9\]\{8\}001".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_access_tier | Input | string | This quickstart | Hot
account_replication_type | Input | string | This quickstart | LRS (default)
tags | Input | string | This quickstart | See previous sample for shared resource group
storage_account_01_id | Output | string | This quickstart | TBD
storage_account_01_name | Output | string | This quickstart | TBD

#### Private endpoint

Shared [private endpoint](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints) for use with shared file share described later.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | string | This quickstart | See previous sample for shared resource group
storage_account_01_private_endpoint_file_id | Output | string | This quickstart | TBD
storage_account_01_private_endpoint_file_prvip | Output | string | This quickstart | TBD

#### File share

Shared [file share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) associated with the shared private endpoint described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_share_quota | Input | string | This quickstart | 1024 (Gb)
storage_share_01_id | Output | string | This quickstart | TBD
storage_share_01_name | Output | string | This quickstart | TBD

#### Private DNS zone

Preconfigured [private DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) *privatelink.file.core.windows.net* for use with the file share private endpoint described previously, and is preconfigured with a [azurerm_private_dns_a_record](https://www.terraform.io/docs/providers/azurerm/r/private_dns_a_record.html) and a [virtual network link](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links) to the shared hub virtual network described previously.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | string | This quickstart | See previous sample for shared resource group
private_dns_zone_1_id | Output | string | This quickstart | TBD
private_dns_zone_1_name | Output | string | This quickstart | TBD
private_dns_a_record_1_id | Output | string | This quickstart | TBD
private_dns_a_record_1_name | Output | string | This quickstart | TBD
virtual_network_link_hub_id | Output | string | This quickstart | TBD
virtual_network_link_hub_name | Output | string | This quickstart | TBD

### Key vault

---

Shared [key vault](https://docs.microsoft.com/en-us/azure/key-vault/) with an automatically generated random name following the grep format "kv-\[a-z0-9\]\{8\}-001". The output variables *key_vault_01_name* and *key_vault_01_id* are used by other configurations to set and retrieve secrets, and the following options are set to *true*:  

* [enabled_for_deployment](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_deployment)  
* [enabled_for_disk_encryption](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_disk_encryption)  
* [enabled_for_template_deployment](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_template_deployment)  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
aad_tenant_id | Input | string | This quickstart | 00000000-0000-0000-0000-000000000000
key_vault_sku_name | Input | string | This quickstart | standard (default)
tags | Input | string | This quickstart | See previous sample for shared resource group
key_vault_01_id | Output | string | All quickstarts | TBD
key_vault_01_name | Output | string | All quickstarts | TBD
key_vault_01_uri | Output | string | This quickstart | TBD

#### Access policy

Shared key vault [access policy](https://docs.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault#data-plane-and-access-policies) for the security principal associated with *key_vault_admin_object_id* with the following [secret access control permissions](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets#secret-access-control):

* backup  
* delete  
* get
* list
* purge
* recover
* restore
* set

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
aad_tenant_id | Input | string | This quickstart | 00000000-0000-0000-0000-000000000000
key_vault_admin_object_id | Input | string | This quickstart | 00000000-0000-0000-0000-000000000000
key_vault_01_access_policy_secrets_admin_id | Output | string | This quickstart | TBD

### Log analytics workspace

---

Shared [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment) with an automatically generated random name following the grep format "log-\[a-z0-9\]\{8\}-001". The [sku](https://www.terraform.io/docs/providers/azurerm/r/log_analytics_workspace.html#sku) is set to *PerGB2018* by default. The *log_analytics_workspace_01_workspace_id* and *log_analytics_workspace_01_primary_shared_key* output variables are used to connect to this log analytics workspace from other configurations.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_retention_days | Input | string | This quickstart | 30 (default)
tags | Input | string | This quickstart | See previous sample for shared resource group
log_analytics_workspace_01_id | Output | string | This quickstart | TBD
log_analytics_workspace_01_name | Output | string | This quickstart | TBD
log_analytics_workspace_01_workspace_id | Output | string | All quickstarts | TBD
log_analytics_workspace_01_primary_shared_key | Output | string | All quickstarts | TBD

### Image gallery

---

Shared [image gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries) with an automatically generated random name following the grep format "sig\[a-z0-9\]\{8\}001".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | string | This quickstart | See previous sample for shared resource group
shared_image_gallery_01_id | Output | string | This quickstart | TBD
shared_image_gallery_01_name| Output | string | This quickstart | TBD
shared_image_gallery_01_unique_name | Output | This quickstart | TBD

### Bastion

---

Dedicated [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) with an automatically generated random name following the grep format "bst-\[a-z0-9\]\{8\}-001" that is associated with subnet\[1\] as described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | string | This quickstart | See previous sample for shared resource group
bastion_host_01_dns_name | Output | string | This quickstart | TBD
bastion_host_01_id | Output | string | This quickstart | TBD
bastion_host_01_name | Output | string | This quickstart | TBD

#### Public ip

Dedicated standard static [public ip](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses) for use with bastion with an automatically generated name following the grep format "pip-\[a-z0-9\]\{8\}-001".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | string | This quickstart | See previous sample for shared resource group
public_ip_bastion_host_01_id | Output | string | This quickstart | TBD
public_ip_bastion_host_01_ip_address | Output | string | This quickstart | TBD
public_ip_bastion_host_01_name | Output | string | This quickstart | TBD

