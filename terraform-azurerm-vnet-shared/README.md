# #AzureQuickStarts - terraform-azurerm-vnet-shared  

## Overview

This quick start implements a shared services [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet). It is the primary building block upon which all the other quick starts are built.

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~20 minutes
Smoke testing | ~5 minutes
De-provisioning | ~15 minutes

## Getting started

This section describes how to provision this quick start using default settings.

* Run `az logout` and `az account clear` to reset the subscription credentials used by Azure CLI.
* Run `az login` and sign in using the credentials associated with the subscription you intend to use for the quick starts.
* Run `az account list -o table` and copy the *Subscription Id* to be used for the quick starts.
* Run `az account set -s 00000000-0000-0000-0000-000000000000` using the *Subscription Id* from the previous step to set the default subscription.
* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the plan.

## Resource index

This section provides an index of the 33 resources included in this quick start.

### Resource group

---

[Resource group](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#resource-group) used by all quick start configurations. Note there are dependencies on this resource in the following quick starts:  

* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)
* [terraform-azurerm-vwan](../terraform-azurerm-vwan)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
resource_group_name | Input | string | Local | rg-vdc-nonprod-01
location | Input | string | Local | eastus2
tags | Input | map | Local | { project = "#AzureQuickStarts", costcenter  = "10177772", environment = "dev" }
resource_group_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01
resource_group_01_location | Output | string | Global | eastus2
resource_group_01_name | Output | string | Global | rg-vdc-nonprod-01
resource_group_01_tags | Output | map | Global | { project = "#AzureQuickStarts", costcenter = "10177772", environment = "dev" }

### Virtual network

---

Shared services [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet). Note there are dependencies on this resource in the following quick starts:  

* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)
* [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vwan](../terraform-azurerm-vwan)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_name | Input | string | Local | vnet-shared-01
address_space | Input | string | Local | 10.1.0.0/16
dns_server | Input | string | Global |10.1.3.4
vnet_shared_01_id | output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01
vnet_shared_01_name | output | string | Global | vnet-shared-01

#### Subnets

The shared services virtual network is divided into [subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets). Note the following subnets used in the sample values are significant:

* A *default* subnet named is required for use in other quick starts.
* A *PrivateLink* subnet is required for use by the file share resource.  
* An *AzureBastionSubnet* subnet is required for use by the bastion resource.  
* An *adds* subnet is required for use for use in other quick starts.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
subnets | Input | map | Local | { default = { name = "snet-default-01", address_prefix = "10.1.0.0/24", enforce_private_link_endpoint_network_policies = false }, AzureBastionSubnet = { name = "AzureBastionSubnet", address_prefix = "10.1.1.0/27", enforce_private_link_endpoint_network_policies = false }, PrivateLink = {  name = "snet-storage-private-endpoints-01", address_prefix = "10.1.2.0/24", enforce_private_link_endpoint_network_policies = true }, adds = {  name = "snet-adds-01", address_prefix = "10.1.3.0/24", enforce_private_link_endpoint_network_policies = false } }
vnet_shared_01_default_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01/subnets/snet-default-01
vnet_shared_01_adds_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-shared-01/subnets/snet-adds-01

#### Bastion

Dedicated [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) with an automatically generated random name following the grep format "bst-\[a-z0-9\]\{16\}-01" that is associated with the subnet *AzureBastionSubnet* as described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
bastion_host_01_dns_name | Output | string | Local | Obfuscated for security
bastion_host_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/bastionHosts/bst-17e10ebde0c9ea93-01
bastion_host_01_name | Output | string | Local | bst-17e10ebde0c9ea93-01

##### Public ip

Dedicated standard static [public ip](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses) for use with bastion with an automatically generated name following the grep format "pip-\[a-z0-9\]\{16\}-01".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
public_ip_bastion_host_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/publicIPAddresses/pip-a787e872af5552b8-01
public_ip_bastion_host_01_ip_address | Output | string | Local | Obfuscated for security
public_ip_bastion_host_01_name | Output | string | Local | pip-a787e872af5552b8-01

### Storage account

---

Shared general-purpose v2 standard [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account) with an automatically generated random name following the grep format "st\[a-z0-9\]\{16\}01". Note there are dependencies on this resource in the following quick starts:  

* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_access_tier | Input | string | Local | Hot (default)
account_replication_type | Input | string | Local | LRS (default)
storage_account_01_blob_endpoint | Output | string | Global | <https://st8e644ec51c5be09801.blob.core.windows.net/>
storage_account_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Storage/storageAccounts/st60fb9730bfbe8ba901
storage_account_01_key | Output | string | Global | Obfuscated for security
storage_account_01_name | Output | string | Global | st60fb9730bfbe8ba901

#### Blob storage container

Shared blob storage container for scripts.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_container_name | Input | string | Local | scripts (default)
storage_container_01_name | Output | string | Global | scripts
storage_container_01_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Storage/storageAccounts/st8e644ec51c5be09801/blobServices/default/containers/scripts

#### Private endpoint

Shared [private endpoint](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints) with an automatically generated random name following the grep format "pend-\[a-z0-9\]\{16\}-01" for use with file share described later.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_account_01_private_endpoint_file_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateEndpoints/pend-9080ddc3a5e17562-01
storage_account_01_private_endpoint_file_name | Output | string | Local | pend-9080ddc3a5e17562-01
storage_account_01_private_endpoint_file_prvip | Output | string | Local | 10.1.2.4

#### File share

Shared [file share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) with an automatically generated random name following the grep format "fs-\[a-z0-9\]\{16\}-01" associated with the private endpoint described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_share_quota | Input | string | Local | 1024 (Gb)
storage_share_01_id | Output | string | Local | Obfuscated for security
storage_share_01_name | Output | string | Local | fs-60fb9730bfbe8ba9-01

#### Private DNS zone

Shared [private DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) *privatelink.file.core.windows.net* for use with the file share private endpoint described previously. Note there is a dependency on this resource in [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_zone_1_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net
private_dns_zone_1_name | Output | string | Global | privatelink.file.core.windows.net

##### Private DNS zone A record

A DNS A record is created in the private DNS zone with a default ttl of 300. The name of the A record is set to the name of the storage account.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_a_record_1_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net/A/st60fb9730bfbe8ba901
private_dns_a_record_1_name | Output | string | Local | st60fb9730bfbe8ba901

##### Private DNS zone virtual network link

A [virtual network link](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links) to the shared services virtual network is established with the private DNS zone *privatelink.file.core.windows.net* for use with the file share private endpoint resource.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_network_link_vnet_shared_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net/virtualNetworkLinks/pdnslnk-vnet-shared-01-01
virtual_network_link_vnet_shared_01_name | Output | string | Local | pdnslnk-vnet-shared-01-01

### Key vault

---

[Key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) with an automatically generated random name following the grep format "kv-\[a-z0-9\]\{16\}-01". The output variables *key_vault_01_name* and *key_vault_01_id* are used by other configurations to set and retrieve secrets, and the following options are set to *true*:  

* [enabled_for_deployment](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_deployment)  
* [enabled_for_disk_encryption](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_disk_encryption)  
* [enabled_for_template_deployment](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_template_deployment)  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
aad_tenant_id | Input | string | Local |00000000-0000-0000-0000-000000000000
key_vault_sku_name | Input | string | Local | standard (default)
key_vault_01_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.KeyVault/vaults/kv-e054bd29698d4fc7-01
key_vault_01_name | Output | string | Global | kv-e054bd29698d4fc7-01
key_vault_01_uri | Output | string | Local | Obfuscated for security

#### Key vault access policy

Key vault [access policy](https://docs.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault#data-plane-and-access-policies) for the security principal associated with *key_vault_admin_object_id* with the following [secret access control permissions](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets#secret-access-control):

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
aad_tenant_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
key_vault_admin_object_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
key_vault_01_access_policy_secrets_admin_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.KeyVault/vaults/kv-e054bd29698d4fc7-01/objectId/00000000-0000-0000-0000-000000000000

### Log analytics workspace

---

Shared [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment) with an automatically generated random name following the grep format "log-\[a-z0-9\]\{16\}-01". The [sku](https://www.terraform.io/docs/providers/azurerm/r/log_analytics_workspace.html#sku) is set to *PerGB2018* by default. The *log_analytics_workspace_01_workspace_id* and *log_analytics_workspace_01_primary_shared_key* output variables are used to connect to this log analytics workspace from other quick starts.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_retention_days | Input | string | Local | 30 (default)
log_analytics_workspace_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-vdc-nonprod-01/providers/microsoft.operationalinsights/workspaces/log-1e884cca24cd4f8c-01
log_analytics_workspace_01_name | Output | string | Local | log-1e884cca24cd4f8c-01
log_analytics_workspace_01_workspace_id | Output | string | Global | 00000000-0000-0000-0000-000000000000
log_analytics_workspace_01_primary_shared_key | Output | string | Global | Obfuscated for security

### Recovery services vault

---

[Recovery services vault](https://docs.microsoft.com/en-us/azure/backup/backup-azure-recovery-services-vault-overview) with an automatically generated random name following the grep pattern "rsv-\[a-z0-9\]\{16\}-01". This is intended to be used for [Azure VM backup](https://docs.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction). Note that soft delete is disabled by default to enable easy cleanup of this quick start, and should be enabled for production environments. Backups must be manually deleted first before attempting to destroy the recovery services vault. See [Proper way to delete a vault](https://docs.microsoft.com/en-us/azure/backup/backup-azure-delete-vault#proper-way-to-delete-a-vault) for more information.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
recovery_services_vault_soft_delete_enabled | Input | bool | Local | false
recovery_services_vault_01_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.RecoveryServices/vaults/rsv-176bda033fa422f5-01
recovery_services_vault_01_name | Output | string | Global | rsv-176bda033fa422f5-01

## Smoke testing

* Explore your newly provisioned resources in the Azure portal.
* Run `terraform destroy` to understand how de-provisioning works.
* Run `terraform apply` to re-apply the configuration.
* Run `terraform output` to view the output variables from the *terraform.tfstate* file.

## Next steps

* Move on to the next quick start [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) and/or [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux).

## Known issues

* [#12447](https://github.com/terraform-providers/terraform-provider-azurerm/issues/12447)
