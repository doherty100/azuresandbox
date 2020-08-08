variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}

variable "location" {
  type        = string
  description = "The Azure region where the VMs will be provisioned"
}

variable "log_analytics_workspace_id" {
  type = string
  description = "The workspaceId of the log analytics workspace used to monitor the VMs"
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group where the VMs will be provisioned"
}

variable "storage_account_name" {
  type = string
  description = "The name of the shared storage account."
}

variable "tags" {
  type = map
  description = "The ARM tags to be applied to all new resources created."
}

variable "vm_admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"
}

variable "vm_admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}

variable "vm_db_data_disk_config" {
  type = map
  description = "Data disk configuration for SQL Server virtual machine."
  # default = { 
  #   datadisk = {
  #     name = "dsk_sqldata_001", 
  #     disk_size_gb = "128", 
  #     lun = "0",
  #     caching = "ReadOnly"
  #   },
  #   logdisk = {
  #     name = "dsk_sqllog_001", 
  #     disk_size_gb = "32", 
  #     lun = "1",
  #     caching = "None"
  #   }
  # }
}

variable "vm_db_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the database server VM"
}

variable "vm_db_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the database server VM"
}

variable "vm_db_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the database server VM"
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

variable "vm_db_post_deploy_script_name" {
  type = string
  description = "The name of the PowerShell script to be run post-deployment."
}

variable "vm_db_post_deploy_script_uri" {
  type = string
  description = "The uri of the PowerShell script to be run post-deployment."
}

variable "vm_db_size" {
  type        = string
  description = "The size of the virtual machine"
}

variable "vm_db_storage_replication_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS disk"
}

variable "vm_db_subnet_id" {
  type        = string
  description = "The existing subnet which will be used by the VM"
}

variable "vm_web_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the database server VM"
}

variable "vm_web_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the database server VM"
}

variable "vm_web_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the database server VM"
}

variable "vm_web_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the database server VM"
  default     = "Latest"
}

variable "vm_web_name" {
  type        = string
  description = "The name of the database server VM"
}

variable "vm_web_post_deploy_script_name" {
  type = string
  description = "The name of the PowerShell script to be run post-deployment."
}

variable "vm_web_post_deploy_script_uri" {
  type = string
  description = "The uri of the PowerShell script to be run post-deployment."
}

variable "vm_web_size" {
  type        = string
  description = "The size of the virtual machine"
}

variable "vm_web_storage_replication_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS disk"
}

variable "vm_web_subnet_id" {
  type        = string
  description = "The existing subnet which will be used by the VM"
}
