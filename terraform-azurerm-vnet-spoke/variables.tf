variable "bastion_host_ip_name" {
  type        = string
  description = "The name of the new public ip used by the bastion host."
  default     = "public_ip_azure_bastion_02"
}

variable "bastion_host_name" {
  type        = string
  description = "The name of the new bastion host."
}

variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "private_dns_zone_name" {
  type = string
  description = "The name of the new private dns zone to be linked to the new spoke vnet."
  # default = "mydomain.private.com"
}

variable "remote_virtual_network_id" {
  type        = string
  description = "The id of the existing hub virtual network that the new spoke virtual network will be peered with."
}

variable "remote_virtual_network_name" {
  type        = string
  description = "The name of the existing hub virtual network that the new spoke virtual network will be peered with."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group for provisioning resources."
}

variable "subnets" {
  type        = map
  description = "The list of subnets to be created in the new spoke virtual network."

  # default = { DefaultSubnet = "10.1.0.0/24" , AzureBastionSubnet = "10.1.1.0/27"}
}

variable "tags" {
  type        = map
  description = "The tags in map format to be used when creating new resources."

  # default = { costcenter = "MyCostCenter", division = "MyDivision", group = "MyGroup" }
}

variable "vnet_address_space" {
  type        = string
  description = "The address space in CIDR notation for the new spoke virtual network."
}

variable "vnet_name" {
  type        = string
  description = "The name of the spoke virtual network."
}
