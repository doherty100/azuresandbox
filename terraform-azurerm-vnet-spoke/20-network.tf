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

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.vnet_spoke_01.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_spoke_01.name
  address_prefixes     = [each.value]
}

output "vnet_spoke_01_subnets" {
  value = azurerm_subnet.vnet_spoke_01_subnets
}

output "vnet_spoke_01_default_subnet_id" {
  value = azurerm_subnet.vnet_spoke_01_subnets["snet-default-002"].id
}

resource "random_id" "random_id_bastion_host_02_name" {
  byte_length = 8
}

# Dedicated bastion
resource "azurerm_bastion_host" "bastion_host_02" {
  name                = "bst-${random_id.random_id_bastion_host_02_name.hex}-002"
  location            = azurerm_virtual_network.vnet_spoke_01.location
  resource_group_name = azurerm_virtual_network.vnet_spoke_01.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "ipc-${random_id.random_id_bastion_host_02_name.hex}-001"
    subnet_id            = azurerm_subnet.vnet_spoke_01_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.public_ip_bastion_host_02.id
  }
}

output "bastion_host_02_dns_name" {
  value = azurerm_bastion_host.bastion_host_02.dns_name
}

output "bastion_host_02_id" {
  value = azurerm_bastion_host.bastion_host_02.id
}

output "bastion_host_02_name" {
  value = azurerm_bastion_host.bastion_host_02.name
}

resource "random_id" "random_id_public_ip_bastion_host_02_name" {
  byte_length = 8
}

resource "azurerm_public_ip" "public_ip_bastion_host_02" {
  name                = "pip-${random_id.random_id_public_ip_bastion_host_02_name.hex}-002"
  location            = azurerm_virtual_network.vnet_spoke_01.location
  resource_group_name = azurerm_virtual_network.vnet_spoke_01.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

output "public_ip_bastion_host_02_id" {
  value = azurerm_public_ip.public_ip_bastion_host_02.id
}

output "public_ip_bastion_host_02_ip_address" {
  value = azurerm_public_ip.public_ip_bastion_host_02.ip_address
}

output "public_ip_bastion_host_02_ip_name" {
  value = azurerm_public_ip.public_ip_bastion_host_02.name
}

# Bi-directional virtual network peering between hub and spoke virtual networks
resource "azurerm_virtual_network_peering" "vnet_hub_01_to_vnet_spoke_01_peering" {
  name                         = "vnet_hub_01_to_vnet_spoke_01_peering"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.remote_virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_spoke_01.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

output "vnet_hub_01_to_vnet_spoke_01_peering_id" {
  value = azurerm_virtual_network_peering.vnet_hub_01_to_vnet_spoke_01_peering.id
}

output "vnet_hub_01_to_vnet_spoke_01_peering_name" {
  value = azurerm_virtual_network_peering.vnet_hub_01_to_vnet_spoke_01_peering.name
}

resource "azurerm_virtual_network_peering" "vnet_spoke_01_to_vnet_hub_01_peering" {
  name                         = "vnet_spoke_01_to_vnet_hub_01_peering"
  resource_group_name          = azurerm_virtual_network.vnet_spoke_01.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_spoke_01.name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

output "vnet_spoke_01_to_vnet_hub_01_peering_id" {
  value = azurerm_virtual_network_peering.vnet_spoke_01_to_vnet_hub_01_peering.id
}

output "vnet_spoke_01_to_vnet_hub_01_peering_name" {
  value = azurerm_virtual_network_peering.vnet_spoke_01_to_vnet_hub_01_peering.name
}

# Private DNS zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_vnet_spoke_01" {
  name                  = "pdnslnk-${azurerm_virtual_network.vnet_spoke_01.name}-002"
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
