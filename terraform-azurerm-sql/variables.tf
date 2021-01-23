variable "admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"
}

variable "admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}

variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}

variable "location" {
  type        = string
  description = "The Azure region where the VMs will be provisioned"
}

variable "private_endpoints_subnet_id" {
  type        = string
  description = "The subnet id to use for private endpoints."
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group where the VMs will be provisioned"
}

variable "sql_database_name" {
  type        = string
  description = "The name of the Azure SQL Database to be provisioned"
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}

variable "tags" {
  type        = map
  description = "The ARM tags to be applied to all new resources created."
}

variable "vnet_id" {
  type = string
  description = "The id of the virtual network for linking the private dns zone."
}

variable "vnet_name" {
  type = string
  description = "The name of virtual network for linking the private dns zone."
}
