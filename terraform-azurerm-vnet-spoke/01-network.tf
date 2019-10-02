resource "azurerm_virtual_network" "vnet_spoke" {
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_address_space}"]
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet_spoke_subnets" {
  count                = "${length(var.subnets)}"
  name                 = "${element(var.subnets.*.name, count.index)}"
  resource_group_name  = "${azurerm_virtual_network.vnet_spoke.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_spoke.name}"
  address_prefix       = "${element(var.subnets.*.address_prefix, count.index)}"
}

resource "azurerm_virtual_network_peering" "spoke_to_hub_peering" {
  name                         = "spoke_to_hub_peering"
  resource_group_name          = "${azurerm_virtual_network.vnet_spoke.resource_group_name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet_spoke.name}"
  remote_virtual_network_id    = "${var.remote_virtual_network_id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_peering" {
  name                         = "hub_to_spoke_peering"
  resource_group_name          = "${var.resource_group_name}"
  virtual_network_name         = "${var.remote_virtual_network_name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet_spoke.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

output "vnet_spoke_id" {
  value = "${azurerm_virtual_network.vnet_spoke.id}"
}

output "vnet_spoke_subnet_ids" {
  value = "${azurerm_subnet.vnet_spoke_subnets.*.id}"
}

output "spoke_to_hub_peering_id" {
  value = "${azurerm_virtual_network_peering.spoke_to_hub_peering.id}"
}

output "hub_to_spoke_peering_id" {
  value = "${azurerm_virtual_network_peering.hub_to_spoke_peering.id}"
}
