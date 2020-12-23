variable "aad_tenant_id" {
  type        = string
  description = "The Azure Active Directory tenant id to be associated with the new key vault."
}

variable "backup_policy_retention_daily" {
  type        = number
  description = "The number of daily backups that should be retained."
  default     = 7
}

variable "backup_policy_time" {
  type        = string
  description = "The time of day to start backup jobs."
  default     = "04:00"
}

variable "backup_policy_timezone" {
  type        = string
  description = "The default time zone to be used for be used for backups."
  default     = "UTC"
}

variable "key_vault_sku_name" {
  type        = string
  description = "The name of the SKU to be used for the new key vault."
  default     = "standard"
}

variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "log_analytics_workspace_retention_days" {
  type        = string
  description = "The retention period for the new log analytics workspace."
  default     = "30"
}

variable "owner_object_id" {
  type        = string
  description = "The object id of the security principal (user or group) with owner rights."
}

variable "recovery_services_vault_soft_delete_enabled" {
  type        = bool
  description = "Sets whether soft delete is enabled on the recovery services vault. Set to true for production environments."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the new resource group to be provisioned."
}

variable "storage_access_tier" {
  type        = string
  description = "The acccess tier for the new storage account."
  default     = "Hot"
}

variable "storage_container_name" {
  type        = string
  description = "The name for the new blob storage container"
  default     = "scripts"
}

variable "storage_replication_type" {
  type        = string
  description = "The type of replication for the new storage account."
  default     = "LRS"
}

variable "storage_share_quota_gb" {
  type        = string
  description = "The storage quota for the Azure Files share to be provisioned in GB."
  default     = "1024"
}

variable "subnets" {
  type        = map(any)
  description = "The subnets to be created in the new virtual network. AzureBastionSubnet is required."
  # default = {
  #   default = {
  #     name                                           = "snet-default-001",
  #     address_prefix                                 = "10.1.0.0/24",
  #     enforce_private_link_endpoint_network_policies = false
  #   },
  #   AzureBastionSubnet = {
  #     name                                           = "AzureBastionSubnet",
  #     address_prefix                                 = "10.1.1.0/27",
  #     enforce_private_link_endpoint_network_policies = false
  #   },
  #   private_endpoints = {
  #     name                                           = "snet-storage-private-endpoints-001",
  #     address_prefix                                 = "10.1.2.0/24",
  #     enforce_private_link_endpoint_network_policies = true
  #   }
  # }
}

variable "tags" {
  type        = map(any)
  description = "The tags in map format to be used when creating new resources."

  default = { costcenter = "MyCostCenter", division = "MyDivision", group = "MyGroup" }
}

variable "vnet_address_space" {
  type        = string
  description = "The address space in CIDR notation for the new virtual network."
}

variable "vnet_name" {
  type        = string
  description = "The name of the new virtual network to be provisioned."
}
