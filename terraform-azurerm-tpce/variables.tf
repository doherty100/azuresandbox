variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}

variable "location" {
  type        = string
  description = "The Azure region where the VM will be provisioned"
}

variable "log_analytics_workspace_id" {
  type = string
  description = "The workspaceId of the log analytics workspace used to monitor the VM"
}

variable "post_deploy_script_name" {
  type = string
  description = "The name of the PowerShell script to be run post-deployment."
}

variable "post_deploy_script_uri" {
  type = string
  description = "The uri of the PowerShell script to be run post-deployment."
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group where the VM will be provisioned"
}

variable "storage_account_name" {
  type = string
  description = "The name of the shared storage account."
}

variable "subnet_id" {
  type        = string
  description = "The existing subnet which will be used by the VM"
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

variable "vm_data_disk_count" {
  type = string
  description = "The number of data disks to be attached to the virtual machine."
}

variable "vm_data_disk_size_gb" {
  type = string
  description = "The number of data disks to be attached to the virtual machine."
}

variable "vm_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
}

variable "vm_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
}

variable "vm_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
}

variable "vm_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"
}

variable "vm_name" {
  type        = string
  description = "The name of the VM"
}

variable "vm_size" {
  type        = string
  description = "The size of the virtual machine"
}

variable "vm_storage_replication_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS disk"
}

