variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "remote_virtual_network_id" {
  type = string
  description = "The id of the hub vnet to be connected to the vwan hub."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group."
}

variable "tags" {
  type        = map
  description = "The tags in map format to be used when creating new resources."

  # default = { costcenter = "MyCostCenter", division = "MyDivision", group = "MyGroup" }
}

variable "vwan_hub_address_prefix" {
  type        = string
  description = "The address prefix in CIDR notation for the new spoke virtual wan hub."
}

variable "vwan_hub_connection_name_1" {
  type = string
  description = "The name of the virtual wan hub connection to the hub virtual network."
}

variable "vwan_hub_name" {
  type = string
  description = "the name of the new virtual wan hub to be provisioned."
}

variable "vwan_name" {
  type = string
  description = "The name of the new virtual wan to be provisioned."
}
