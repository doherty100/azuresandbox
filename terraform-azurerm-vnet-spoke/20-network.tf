# Dedicated spoke vnet
resource "azurerm_virtual_network" "vnet_spoke_01" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

output "vnet_spoke_01_id" {
  value = azurerm_virtual_network.vnet_spoke_01.id
}

output "vnet_spoke_01_name" {
  value = azurerm_virtual_network.vnet_spoke_01.name
}

resource "azurerm_subnet" "vnet_spoke_01_subnets" {
  for_each = var.subnets

  name                                           = each.value.name
  resource_group_name                            = azurerm_virtual_network.vnet_spoke_01.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet_spoke_01.name
  address_prefixes                               = [ each.value.address_prefix ]
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
}

output "vnet_spoke_01_app_subnet_id" {
  value = azurerm_subnet.vnet_spoke_01_subnets["application"].id
}

output "vnet_spoke_01_db_subnet_id" {
  value = azurerm_subnet.vnet_spoke_01_subnets["database"].id
}

output "vnet_spoke_01_default_subnet_id" {
  value = azurerm_subnet.vnet_spoke_01_subnets["default"].id
}

output "vnet_spoke_01_private_endpoints_subnet_id" {
  value = azurerm_subnet.vnet_spoke_01_subnets["PrivateLink"].id
}

# Bi-directional virtual network peering between shared services and spoke virtual networks
resource "azurerm_virtual_network_peering" "vnet_shared_01_to_vnet_spoke_01_peering" {
  name                         = "vnet_shared_01_to_vnet_spoke_01_peering"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.remote_virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_spoke_01.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

output "vnet_shared_01_to_vnet_spoke_01_peering_id" {
  value = azurerm_virtual_network_peering.vnet_shared_01_to_vnet_spoke_01_peering.id
}

output "vnet_shared_01_to_vnet_spoke_01_peering_name" {
  value = azurerm_virtual_network_peering.vnet_shared_01_to_vnet_spoke_01_peering.name
}

resource "azurerm_virtual_network_peering" "vnet_spoke_01_to_vnet_shared_01_peering" {
  name                         = "vnet_spoke_01_to_vnet_shared_01_peering"
  resource_group_name          = azurerm_virtual_network.vnet_spoke_01.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_spoke_01.name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

output "vnet_spoke_01_to_vnet_shared_01_peering_id" {
  value = azurerm_virtual_network_peering.vnet_spoke_01_to_vnet_shared_01_peering.id
}

output "vnet_spoke_01_to_vnet_shared_01_peering_name" {
  value = azurerm_virtual_network_peering.vnet_spoke_01_to_vnet_shared_01_peering.name
}

# Private DNS zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_vnet_spoke_01" {
  name                  = "pdnslnk-${azurerm_virtual_network.vnet_spoke_01.name}-02"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = "privatelink.file.core.windows.net"
  virtual_network_id    = azurerm_virtual_network.vnet_spoke_01.id
  registration_enabled  = false
  tags                  = var.tags
}

output "virtual_network_link_vnet_spoke_01_id" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_vnet_spoke_01.id
}

output "virtual_network_link_vnet_spoke_01_name" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_vnet_spoke_01.name
}
