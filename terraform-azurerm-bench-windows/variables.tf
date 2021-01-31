variable "admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"
}

variable "admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}

variable "app_subnet_id" {
  type        = string
  description = "The existing subnet which will be used by the VM"
}

variable "backup_policy_vm_id" {
  type        = string
  description = "The id of the backup policy to be used for VMs."
}

variable "db_subnet_id" {
  type        = string
  description = "The existing subnet which will be used by the VM"
}

variable "key_vault_id" {
  type        = string
  description = "The id of the existing key vault where secrets are stored"
}

variable "key_vault_name" {
  type        = string
  description = "The name of the existing key vault where secrets are stored"
}

variable "location" {
  type        = string
  description = "The Azure region where the VMs will be provisioned"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The workspaceId of the log analytics workspace used to monitor the VMs"
}

variable "rbac_role_key_vault_secrets_user" {
  type        = string
  description = "The name of the RBAC role for 'Key Vault Secrets User'"
  default     = "Key Vault Secrets User"
}

variable "recovery_services_vault_name" {
  type        = string
  description = "The name of the recovery services vault used for Azure VM backups."
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group where the VMs will be provisioned"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the shared storage account."
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}

variable "tags" {
  type        = map(any)
  description = "The ARM tags to be applied to all new resources created."
}

# Application VM variables
variable "vm_app_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the application server VM"
  default     = "WindowsServer"
}

variable "vm_app_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the application server VM"
  default     = "MicrosoftWindowsServer"
}

variable "vm_app_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the application server VM"
  default     = "2019-Datacenter-Core"
}

variable "vm_app_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the application server VM"
  default     = "Latest"
}

variable "vm_app_name" {
  type        = string
  description = "The name of the aplication server VM"
}

variable "vm_app_post_deploy_script" {
  type        = string
  description = "The name of the PowerShell script to be run post-deployment."
}

variable "vm_app_post_deploy_script_uri" {
  type        = string
  description = "The uri of the PowerShell script to be run post-deployment."
}

variable "vm_app_size" {
  type        = string
  description = "The size of the virtual machine"
  default     = "Standard_B2s"
}

variable "vm_app_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS disk"
  default     = "Standard_LRS"
}

# Database VM variables
variable "vm_db_data_disk_config" {
  type        = map(any)
  description = "Data disk configuration for SQL Server virtual machine."
  default = {
    sqldata = {
      name         = "vol_sqldata_M",
      disk_size_gb = "128",
      lun          = "0",
      caching      = "ReadOnly"
    },
    sqllog = {
      name         = "vol_sqllog_L",
      disk_size_gb = "32",
      lun          = "1",
      caching      = "None"
    }
  }
}

variable "vm_db_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the database server VM"
  default     = "sql2019-ws2019"
}

variable "vm_db_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the database server VM"
  default     = "MicrosoftSQLServer"
}

variable "vm_db_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the database server VM"
  default     = "sqldev"
}

variable "vm_db_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the database server VM"
  default     = "Latest"
}

variable "vm_db_name" {
  type        = string
  description = "The name of the database server VM"
}

variable "vm_db_post_deploy_script" {
  type        = string
  description = "The name of the PowerShell script to be run post-deployment."
}

variable "vm_db_post_deploy_script_uri" {
  type        = string
  description = "The uri of the PowerShell script to be run post-deployment."
}

variable "vm_db_size" {
  type        = string
  description = "The size of the virtual machine"
  default     = "Standard_B4ms"
}

variable "vm_db_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS disk"
  default     = "StandardSSD_LRS"
}

variable "vm_db_sql_startup_script" {
  type        = string
  description = "The name of the SQL Startup Powershell script."
}

variable "vm_db_sql_startup_script_uri" {
  type        = string
  description = "The URI for the SQL Startup Powershell script."
}
