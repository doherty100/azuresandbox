variable "aad_tenant_id" {
  type = "string"
  description = "The Azure Active Directory tenant id to be associated with the new key vault."
}

variable "key_vault_admin_object_id" {
  type = "string"
  description = "The object id of the security principle (user or group) with administrative rights for the new key vault."
}

variable "key_vault_name" {
  type = "string"
  description = "The name of the new key vault to provision."
}

variable "key_vault_sku_name" {
  type = "string"
  description = "The name of the SKU to be used for the new key vault."
  default = "standard"
}

variable "location" {
  type        = "string"
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "log_analytics_workspace_name" {
  type = "string"
  description = "The name of the new log analytics workspace."
}

variable "log_analytics_workspace_retention_days" {
  type = "string"
  description = "The retention period for the new log analytics workspace."
  default = "30"
}

variable "resource_group_name" {
  type        = "string"
  description = "The name of the new resource group to be provisioned."
}

variable "shared_image_gallery_name" {
  type = "string"
  description = "The name of the new shared image gallery to provision."
}

variable "storage_access_tier" {
  type = "string"
  description = "The acccess tier for the new storage account."
  default = "Hot"
}

variable "storage_account_tier" {
  type = "string"
  description = "The account tier for the new storage account."
  # default = "Standard"
}

variable "storage_replication_type" {
  type = "string"
  description = "The type of replication for the new storage account."
  # default = "LRS"
}

variable "subnets" {
  type        = "list"
  description = "The list of subnets to be created in the new virtual network."

  # default = [ { name = "default", address_prefix = "10.0.0.0/24" }, { name = "GatewaySubnet", address_prefix = "10.0.255.0/27" } ]
}

variable "tags" {
  type        = "map"
  description = "The tags in map format to be used when creating new resources."

  # default = { costcenter = "MyCostCenter", division = "MyDivision", group = "MyGroup" }
}


variable "vnet_address_space" {
  type        = "string"
  description = "The address space in CIDR notation for the new virtual network."
}

variable "vnet_name" {
  type        = "string"
  description = "The name of the new virtual network to be provisioned."
}
