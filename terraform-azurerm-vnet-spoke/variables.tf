variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "remote_virtual_network_id" {
  type        = string
  description = "The id of the existing shared services virtual network that the new spoke virtual network will be peered with."
}

variable "remote_virtual_network_name" {
  type        = string
  description = "The name of the existing shared services virtual network that the new spoke virtual network will be peered with."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group for provisioning resources."
}

variable "subnets" {
  type        = map
  description = "The list of subnets to be created in the new spoke virtual network."
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."
}

variable "tags" {
  type        = map
  description = "The tags in map format to be used when creating new resources."
}

variable "vnet_address_space" {
  type        = string
  description = "The address space in CIDR notation for the new spoke virtual network."
}

variable "vnet_name" {
  type        = string
  description = "The name of the spoke virtual network."
}
