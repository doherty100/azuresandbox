variable "admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"
}

variable "admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
}

variable "app_vm_post_deploy_script_name" {
  type = string
  description = "The name of the PowerShell script to be run post-deployment."
}

variable "app_vm_post_deploy_script_uri" {
  type = string
  description = "The uri of the PowerShell script to be run post-deployment."
}

variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"
}

variable "key_vault_name" {
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

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}

variable "tags" {
  type = map
  description = "The ARM tags to be applied to all new resources created."
}

variable "vm_data_disk_config" {
  type        = map
  description = "The number of data disks to be attached to the virtual machine."
  default = {
    data = {
      name         = "vol_data_N",
      disk_size_gb = "4",
      lun          = "0",
      caching      = "ReadWrite"
    }
  }
}

variable "vm_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default = "UbuntuServer"
}

variable "vm_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default = "Canonical"
}

variable "vm_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default = "18.04-LTS"
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
  default = "Standard_B2s"
}

variable "vm_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks"
  default     = "Standard_LRS"
}
