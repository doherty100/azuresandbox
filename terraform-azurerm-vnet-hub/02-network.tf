resource "azurerm_virtual_network" "vnet_01" {
  name                = "${var.vnet_name}"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  address_space       = ["${var.vnet_address_space}"]

  tags = "${var.tags}"
}

resource "azurerm_subnet" "vnet_01_subnets" {
  count                = "${length(var.subnets)}"
  name                 = "${element(var.subnets.*.name, count.index)}"
  resource_group_name  = "${azurerm_resource_group.resource_group_01.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_01.name}"
  address_prefix       = "${element(var.subnets.*.address_prefix, count.index)}"
}

output "vnet_01_id" {
  value = "${azurerm_virtual_network.vnet_01.id}"
}

output "vnet_01_subnet_ids" {
    value = "${azurerm_subnet.vnet_01_subnets.*.id}"
}