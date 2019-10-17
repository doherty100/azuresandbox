resource "azurerm_virtual_network" "vnet_hub" {
  name                = "${var.vnet_name}"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  address_space       = ["${var.vnet_address_space}"]

  tags = "${var.tags}"
}

resource "azurerm_subnet" "vnet_hub_subnets" {
  count                = "${length(var.subnets)}"
  name                 = "${element(var.subnets.*.name, count.index)}"
  resource_group_name  = "${azurerm_resource_group.resource_group_01.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${element(var.subnets.*.address_prefix, count.index)}"
}

resource "azurerm_public_ip" "public_ip_azure_bastion" {
  name                = "public_ip_azure_bastion"
  location            = "${azurerm_resource_group.resource_group_01.location}"
  resource_group_name = "${azurerm_resource_group.resource_group_01.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = "${var.tags}"
}

output "public_ip_azure_bastion_id" {
  value = "${azurerm_public_ip.public_ip_azure_bastion.id}"
}

output "vnet_hub_id" {
  value = "${azurerm_virtual_network.vnet_hub.id}"
}

output "vnet_hub_subnet_ids" {
  value = "${azurerm_subnet.vnet_hub_subnets.*.id}"
}
