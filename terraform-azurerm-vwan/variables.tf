variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."
}

variable "remote_virtual_network_ids" {
  type        = map
  description = "The ids of the vnets to be connected to the vwan hub."

  # default = { MyHubVNetId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MyHubVNetName", MySpokeVnetId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MySpokeVNetName" } 
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
