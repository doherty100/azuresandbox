variable "aad_tenant_id" {
  type        = string
  description = "The Azure Active Directory tenant id."
}

variable "adds_domain_name" {
  type        = string
  description = "The AD DS domain name."
}

variable "admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"
  default     = "adminpassword"
}

variable "admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"
  default     = "adminuser"
}

variable "arm_client_id" {
  type        = string
  description = "The AppId of the service principal used for authenticating with Azure. Must have a 'Contributor' role assignment."
}

variable "arm_client_secret" {
  type        = string
  description = "The password for the service principal used for authenticating with Azure. Set interactively or using an environment variable 'TF_VAR_arm_client_secret'."
  sensitive   = true
}

variable "automation_credential_name" {
  type        = string
  description = "The name of the Azure automation credential for boostrap admin account."
  default     = "bootstrapadmin"
}

variable "automation_module_ActiveDirectoryDsc_uri" {
  type        = string
  description = "The URI for the ActiveDirectoryDsc package download."
  default     = "https://www.powershellgallery.com/api/v2/package/ActiveDirectoryDsc/6.0.1"
}

variable "automation_module_Az_Automation_uri" {
  type        = string
  description = "The URI for the Az.Automation package download."
  default     = "https://www.powershellgallery.com/api/v2/package/Az.Automation/1.7.0"
}
variable "dns_server" {
  type        = string
  description = "The IP address of the DNS server. This should be the first non-reserved IP address in the subnet where the AD DS domain controller is hosted."
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
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "log_analytics_workspace_retention_days" {
  type        = string
  description = "The retention period for the new log analytics workspace."
  default     = "30"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the new resource group to be provisioned."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the shared storage account."
}

variable "storage_container_name" {
  type        = string
  description = "The name of the blob storage container where scripts are stored."
}

variable "subnets" {
  type        = map(any)
  description = "The subnets to be created in the new virtual network. AzureBastionSubnet is required."
  # default = {
  # default = {
  #   name                                           = "snet-default-01",
  #   address_prefix                                 = "10.1.0.0/24",
  #   enforce_private_link_endpoint_network_policies = false
  # },
  # AzureBastionSubnet = {
  #   name                                           = "AzureBastionSubnet",
  #   address_prefix                                 = "10.1.1.0/27",
  #   enforce_private_link_endpoint_network_policies = false
  # },
  # PrivateLink = {
  #   name                                           = "snet-storage-private-endpoints-01",
  #   address_prefix                                 = "10.1.2.0/24",
  #   enforce_private_link_endpoint_network_policies = true
  # },
  # adds = {
  #   name                                           = "snet-adds-01",
  #   address_prefix                                 = "10.1.3.0/24",
  #   enforce_private_link_endpoint_network_policies = false
  # }
  # }
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}

variable "tags" {
  type        = map(any)
  description = "The tags in map format to be used when creating new resources."

  default = { costcenter = "MyCostCenter", division = "MyDivision", group = "MyGroup" }
}

variable "vm_adds_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "WindowsServer"
}

variable "vm_adds_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "MicrosoftWindowsServer"
}

variable "vm_adds_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "2019-Datacenter-Core"
}

variable "vm_adds_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"
}

variable "vm_adds_name" {
  type        = string
  description = "The name of the VM"
}

variable "vm_adds_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_B2s"
}

variable "vm_adds_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks."
  default     = "Standard_LRS"
}
variable "vm_jumpbox_win_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "WindowsServer"
}

variable "vm_jumpbox_win_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "MicrosoftWindowsServer"
}

variable "vm_jumpbox_win_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "2019-Datacenter"
}

variable "vm_jumpbox_win_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"
}

variable "vm_jumpbox_win_name" {
  type        = string
  description = "The name of the VM"
}

variable "vm_jumpbox_win_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_B2s"
}

variable "vm_jumpbox_win_storage_account_type" {
  type        = string
  description = "The storage replication type to be used for the VMs OS and data disks."
  default     = "Standard_LRS"
}

variable "vnet_address_space" {
  type        = string
  description = "The address space in CIDR notation for the new virtual network."
}

variable "vnet_name" {
  type        = string
  description = "The name of the new virtual network to be provisioned."
}
