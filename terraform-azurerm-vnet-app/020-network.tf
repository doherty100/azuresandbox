# Application virtual network
resource "azurerm_virtual_network" "vnet_app_01" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  dns_servers         = [var.dns_server, "168.63.129.16"]
  tags                = var.tags
}

resource "azurerm_subnet" "vnet_app_01_subnets" {
  for_each = var.subnets

  name                                           = each.value.name
  resource_group_name                            = azurerm_virtual_network.vnet_app_01.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet_app_01.name
  address_prefixes                               = [each.value.address_prefix]
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
}

# Peering with shared services virtual network
resource "azurerm_virtual_network_peering" "vnet_shared_01_to_vnet_app_01_peering" {
  name                         = "vnet_shared_01_to_vnet_app_01_peering"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.remote_virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_app_01.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "vnet_app_01_to_vnet_shared_01_peering" {
  name                         = "vnet_app_01_to_vnet_shared_01_peering"
  resource_group_name          = azurerm_virtual_network.vnet_app_01.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_app_01.name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
