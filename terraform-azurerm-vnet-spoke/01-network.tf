resource "azurerm_virtual_network" "vnet_spoke" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "vnet_spoke_subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  address_prefixes     = [each.value]
}

resource "azurerm_public_ip" "public_ip_azure_bastion_02" {
  name                = "public_ip_azure_bastion_02"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion_host_02" {
  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "${var.bastion_host_name}ipconfig01"
    subnet_id            = azurerm_subnet.vnet_spoke_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.public_ip_azure_bastion_02.id
  }
}

resource "azurerm_virtual_network_peering" "spoke_to_hub_peering" {
  name                         = "spoke_to_hub_peering"
  resource_group_name          = azurerm_virtual_network.vnet_spoke.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_spoke.name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_peering" {
  name                         = "hub_to_spoke_peering"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.remote_virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_spoke" {
  name                  = "${azurerm_virtual_network.vnet_spoke.name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = azurerm_virtual_network.vnet_spoke.id
  registration_enabled  = true
  tags                  = var.tags
}

output "bastion_host_02_id" {
  value = azurerm_bastion_host.bastion_host_02.id
}

output "bastion_host_02_dns_name" {
  value = azurerm_bastion_host.bastion_host_02.dns_name
}

output "hub_to_spoke_peering_id" {
  value = azurerm_virtual_network_peering.hub_to_spoke_peering.id
}

output "public_ip_azure_bastion_02_id" {
  value = azurerm_public_ip.public_ip_azure_bastion_02.id
}

output "spoke_to_hub_peering_id" {
  value = azurerm_virtual_network_peering.spoke_to_hub_peering.id
}

output "virtual_network_link_spoke_id" {
  value = azurerm_private_dns_zone_virtual_network_link.virtual_network_link_spoke.id
}
output "vnet_spoke_id" {
  value = azurerm_virtual_network.vnet_spoke.id
}

output "vnet_spoke_subnets" {
  value = azurerm_subnet.vnet_spoke_subnets
}

