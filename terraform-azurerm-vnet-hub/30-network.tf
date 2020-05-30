# Shared hub virtual network
resource "azurerm_virtual_network" "vnet_hub_01" {
  name                = var.vnet_name
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

output "vnet_hub_01_id" {
  value = azurerm_virtual_network.vnet_hub_01.id
}

output "vnet_hub_01_name" {
  value = azurerm_virtual_network.vnet_hub_01.name
}

output "vnet_hub_01_subnets" {
  value = azurerm_subnet.vnet_hub_01_subnets
}

resource "azurerm_subnet" "vnet_hub_01_subnets" {
  for_each = var.subnets

  name                                           = each.key
  resource_group_name                            = azurerm_resource_group.resource_group_01.name
  virtual_network_name                           = azurerm_virtual_network.vnet_hub_01.name
  address_prefixes                               = [each.value]
  enforce_private_link_endpoint_network_policies = length(regexall("snet-storage-private-endpoints+", each.key)) > 0 ? true : false
}

# Dedicated bastion
resource "random_id" "random_id_bastion_host_01_name" {
  byte_length = 8
}

resource "azurerm_bastion_host" "bastion_host_01" {
  name                = "bst-${random_id.random_id_bastion_host_01_name.hex}-001"
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  tags                = var.tags

  ip_configuration {
    name                 = "ipc-${random_id.random_id_bastion_host_01_name.hex}-001"
    subnet_id            = azurerm_subnet.vnet_hub_01_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.public_ip_bastion_host_01.id
  }
}
output "bastion_host_01_dns_name" {
  value = azurerm_bastion_host.bastion_host_01.dns_name
}

output "bastion_host_01_id" {
  value = azurerm_bastion_host.bastion_host_01.id
}

output "bastion_host_01_name" {
  value = azurerm_bastion_host.bastion_host_01.name
}

# Dedicated public ip for bastion
resource "random_id" "random_id_public_ip_bastion_host_01_name" {
  byte_length = 8
}

resource "azurerm_public_ip" "public_ip_bastion_host_01" {
  name                = "pip-${random_id.random_id_public_ip_bastion_host_01_name.hex}-001"
  location            = azurerm_resource_group.resource_group_01.location
  resource_group_name = azurerm_resource_group.resource_group_01.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

output "public_ip_bastion_host_01_id" {
  value = azurerm_public_ip.public_ip_bastion_host_01.id
}

output "public_ip_bastion_host_01_ip_address" {
  value = azurerm_public_ip.public_ip_bastion_host_01.ip_address
}

output "public_ip_bastion_host_01_name" {
  value = azurerm_public_ip.public_ip_bastion_host_01.name
}

