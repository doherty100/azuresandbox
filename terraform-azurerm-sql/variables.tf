variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}

variable "location" {
  type        = string
  description = "The Azure region where the VMs will be provisioned"
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group where the VMs will be provisioned"
}

variable "sql_admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"
}

variable "sql_admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}

variable "sql_database_name" {
  type        = string
  description = "The name of the Azure SQL Database to be provisioned"
}

variable "tags" {
  type        = map
  description = "The ARM tags to be applied to all new resources created."
}
