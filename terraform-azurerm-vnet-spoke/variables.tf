variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
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
  # default = {
  #   default  = {
  #     name = "snet-default-002", 
  #     address_prefix = "10.2.0.0/24", 
  #     enforce_private_link_endpoint_network_policies = false
  #   },
  #   AzureBastionSubnet = {
  #     name = "AzureBastionSubnet", 
  #     address_prefix = "10.2.1.0/27", 
  #     enforce_private_link_endpoint_network_policies = false
  #   },
  #   database = {
  #     name = "snet-db-001", 
  #     address_prefix = "10.2.1.32/27", 
  #     enforce_private_link_endpoint_network_policies = false
  #   },
  #   application = {
  #     name = "snet-app-001", 
  #     address_prefix = "10.2.1.64/27",
  #     enforce_private_link_endpoint_network_policies = false
  #   }
  # }
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
