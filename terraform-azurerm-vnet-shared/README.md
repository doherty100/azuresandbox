# #AzureQuickStarts - terraform-azurerm-vnet-shared  

## Overview

This quick start implements a shared services [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet). It is the primary building block upon which all the other quick starts are built.

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~10 minutes
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
resource_group_name | Input | string | Local | rg-vdc-nonprod-001
location | Input | string | Local | eastus2
tags | Input | map | Local | { project = "#AzureQuickStarts", costcenter  = "10177772", environment = "dev" }
resource_group_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001
resource_group_01_location | Output | string | Global | eastus2
resource_group_01_name | Output | string | Global | rg-vdc-nonprod-001
resource_group_01_tags | Output | map | Global | { project = "#AzureQuickStarts", costcenter = "10177772", environment = "dev" }

#### Role assignment

[Role assignment](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview#role-assignments) scoped to the resource group which grants ownership rights to a security principal associated with a user or group. Owner privileges are then inherited for all resources contained in the resource group.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
principal_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
resource_group_01_role_assignment_owner_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Authorization/roleAssignments/00000000-0000-0000-0000-000000000000
resource_group_01_role_assignment_owner_principal_type | Output | string | Local | User
resource_group_01_role_assignment_owner_principal_id | Output | string | Global | 00000000-0000-0000-0000-000000000000

### Virtual network

---

Shared services [virtual network](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vnet). Note there are dependencies on this resource in the following quick starts:  

* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)
* [terraform-azurerm-vwan](../terraform-azurerm-vwan)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_name | Input | string | Local | vnet-shared-001
address_space | Input | string | Local | 10.1.0.0/16
vnet_shared_01_id | output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-shared-001
vnet_shared_01_name | output | string | Global | vnet-shared-001

#### Subnets

The shared services virtual network is divided into [subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets). Note the following subnets used in the sample values are significant:

* A *default* subnet named is required for use in other quick starts.
* A *PrivateLink* subnet is required for use by the file share resource.  
* An *AzureBastionSubnet* subnet is required for use by the bastion resource.  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
subnets | Input | map | Local | { default = { name = "snet-default-001", address_prefix = "10.1.0.0/24", enforce_private_link_endpoint_network_policies = false }, AzureBastionSubnet = { name = "AzureBastionSubnet", address_prefix = "10.1.1.0/27", enforce_private_link_endpoint_network_policies = false }, PrivateLink = {  name = "snet-storage-private-endpoints-001", address_prefix = "10.1.2.0/24", enforce_private_link_endpoint_network_policies = true } }
vnet_shared_01_default_subnet_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/virtualNetworks/vnet-shared-001/subnets/snet-default-001

#### Bastion

Dedicated [bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) with an automatically generated random name following the grep format "bst-\[a-z0-9\]\{16\}-001" that is associated with the subnet *AzureBastionSubnet* as described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
bastion_host_01_dns_name | Output | string | Local | Obfuscated for security
bastion_host_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/bastionHosts/bst-17e10ebde0c9ea93-001
bastion_host_01_name | Output | string | Local | bst-17e10ebde0c9ea93-001

##### Public ip

Dedicated standard static [public ip](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses) for use with bastion with an automatically generated name following the grep format "pip-\[a-z0-9\]\{16\}-001".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
public_ip_bastion_host_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/publicIPAddresses/pip-a787e872af5552b8-001
public_ip_bastion_host_01_ip_address | Output | string | Local | Obfuscated for security
public_ip_bastion_host_01_name | Output | string | Local | pip-a787e872af5552b8-001

### Storage account

---

Shared general-purpose v2 standard [storage account](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#storage-account) with an automatically generated random name following the grep format "st\[a-z0-9\]\{16\}001". Note there are dependencies on this resource in the following quick starts:  

* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows)

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_access_tier | Input | string | Local | Hot (default)
account_replication_type | Input | string | Local | LRS (default)
storage_account_01_blob_endpoint | Output | string | Global | <https://st8e644ec51c5be098001.blob.core.windows.net/>
storage_account_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Storage/storageAccounts/st60fb9730bfbe8ba9001
storage_account_01_key | Output | string | Global | Obfuscated for security
storage_account_01_name | Output | string | Global | st60fb9730bfbe8ba9001

#### Blob storage container

Shared blob storage container for scripts.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_container_name | Input | string | Local | scripts (default)
storage_container_01_name | Output | string | Global | scripts
storage_container_01_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Storage/storageAccounts/st8e644ec51c5be098001/blobServices/default/containers/scripts

#### Private endpoint

Shared [private endpoint](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints) with an automatically generated random name following the grep format "pend-\[a-z0-9\]\{16\}-001" for use with shared file share described later.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_account_01_private_endpoint_file_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateEndpoints/pend-9080ddc3a5e17562-001
storage_account_01_private_endpoint_file_name | Output | string | Local | pend-9080ddc3a5e17562-001
storage_account_01_private_endpoint_file_prvip | Output | string | Local | 10.1.2.4

#### File share

Shared [file share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) with an automatically generated random name following the grep format "fs-\[a-z0-9\]\{16\}-001" associated with the shared private endpoint described previously.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
storage_share_quota | Input | string | Local | 1024 (Gb)
storage_share_01_id | Output | string | Local | Obfuscated for security
storage_share_01_name | Output | string | Local | fs-60fb9730bfbe8ba9-001

#### Private DNS zone

Shared [private DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) *privatelink.file.core.windows.net* for use with the file share private endpoint described previously. Note there is a dependency on this resource in [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_zone_1_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net
private_dns_zone_1_name | Output | string | Global | privatelink.file.core.windows.net

##### Private DNS zone A record

A DNS A record is created in the private DNS zone with a default ttl of 300. The name of the A record is set to the name of the shared storage account.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_a_record_1_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net/A/st60fb9730bfbe8ba9001
private_dns_a_record_1_name | Output | string | Local | st60fb9730bfbe8ba9001

##### Private DNS zone virtual network link

A [virtual network link](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links) to the shared services virtual network is established with the private DNS zone *privatelink.file.core.windows.net* for use with the file share private endpoint resource.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_network_link_vnet_shared_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net/virtualNetworkLinks/pdnslnk-vnet-shared-001-001
virtual_network_link_vnet_shared_01_name | Output | string | Local | pdnslnk-vnet-shared-001-001

### Key vault

---

Shared [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) with an automatically generated random name following the grep format "kv-\[a-z0-9\]\{16\}-001". The output variables *key_vault_01_name* and *key_vault_01_id* are used by other configurations to set and retrieve secrets, and the following options are set to *true*:  

* [enabled_for_deployment](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_deployment)  
* [enabled_for_disk_encryption](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_disk_encryption)  
* [enabled_for_template_deployment](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#enabled_for_template_deployment)  

Note there are dependencies on this resource in the the [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) quick start.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
aad_tenant_id | Input | string | Local |00000000-0000-0000-0000-000000000000
key_vault_sku_name | Input | string | Local | standard (default)
key_vault_01_id | Output | string | Global | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.KeyVault/vaults/kv-e054bd29698d4fc7-001
key_vault_01_name | Output | string | Global | kv-e054bd29698d4fc7-001
key_vault_01_uri | Output | string | Local | Obfuscated for security

#### Key vault access policy

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
aad_tenant_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
key_vault_admin_object_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
key_vault_01_access_policy_secrets_admin_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.KeyVault/vaults/kv-e054bd29698d4fc7-001/objectId/00000000-0000-0000-0000-000000000000

### Log analytics workspace

---

Shared [log analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment) with an automatically generated random name following the grep format "log-\[a-z0-9\]\{16\}-001". The [sku](https://www.terraform.io/docs/providers/azurerm/r/log_analytics_workspace.html#sku) is set to *PerGB2018* by default. The *log_analytics_workspace_01_workspace_id* and *log_analytics_workspace_01_primary_shared_key* output variables are used to connect to this log analytics workspace from other configurations. Note there is a dependency on this resource in the [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) quick start.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_retention_days | Input | string | Local | 30 (default)
log_analytics_workspace_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-vdc-nonprod-001/providers/microsoft.operationalinsights/workspaces/log-1e884cca24cd4f8c-001
log_analytics_workspace_01_name | Output | string | Local | log-1e884cca24cd4f8c-001
log_analytics_workspace_01_workspace_id | Output | string | Global | 00000000-0000-0000-0000-000000000000
log_analytics_workspace_01_primary_shared_key | Output | string | Global | Obfuscated for security

### Image gallery

---

[Image gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries) with an automatically generated random name following the grep format "sig\[a-z0-9\]\{16\}001".  

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
shared_image_gallery_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/galleries/sigefc3bc469570d895001
shared_image_gallery_01_name | Output | string | Local | sigefc3bc469570d895001
shared_image_gallery_01_unique_name | Output | string | Local | 00000000-0000-0000-0000-000000000000-SIGEFC3BC469570D895001

### Automation account

---

Automation account for use with [Azure Automation](https://docs.microsoft.com/en-us/azure/automation/automation-intro) features like process automation, configuration management and update management that is linked to the shared log analytics workspace. An automatically generated random name is assigned following the grep pattern "autoacct-\[a-z0-9\]\{16\}-001".

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
automation_account_01_name | Output | string | Local | autoacct-feb1e2ddafa54a87-001

### Recovery services vault

---

[Recovery services vault](https://docs.microsoft.com/en-us/azure/backup/backup-azure-recovery-services-vault-overview) with an automatically generated random name following the grep pattern "rsv-\[a-z0-9\]\{16\}-001". This is intended to be used for [Azure VM backup](https://docs.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction). Soft delete is enabled by default.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
recovery_services_vault_01_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.RecoveryServices/vaults/rsv-176bda033fa422f5-001
recovery_services_vault_01_name | Output | string | Global | rsv-176bda033fa422f5-001

#### Virtual machine backup policy

Pre-configured [Backup policy](https://docs.microsoft.com/en-us/azure/backup/backup-azure-arm-vms-prepare#apply-a-backup-policy) associated with recovery services vault to be used for virtual machine backups. Defaults are configured to backup VMs daily at 04:00 UTC and retain the minimum 7 of daily backups.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
backup_policy_retention_daily | Input | number | Local | 7
backup_policy_time | Input | string | Local | 04:00
backup_policy_timezone | Input | string | Local | UTC
backup_policy_vm_01_id | Output | string | Global | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.RecoveryServices/vaults/rsv-f79aaba266ebcd8c-001/backupPolicies/rsv-rsv-f79aaba266ebcd8c-001-backup-policy-vm

## Smoke testing

* Explore your newly provisioned resources in the Azure portal.
* Run `terraform destroy` to understand how de-provisioning works.
* Run `terraform apply` to re-apply the configuration.
* Run `terraform output` to view the output variables from the *terraform.tfstate* file.

## Next steps

* Move on to the next quick start [terraform-azurerm-vm-windows](../terraform-azurerm-vm-windows) and/or [terraform-azurerm-vm-linux](../terraform-azurerm-vm-linux).
