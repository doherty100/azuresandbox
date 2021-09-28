# Shared services virtual network and subnets
resource "azurerm_virtual_network" "vnet_shared_01" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  dns_servers         = [var.dns_server, "168.63.129.16"]
  tags                = var.tags
}

output "vnet_shared_01_id" {
  value = azurerm_virtual_network.vnet_shared_01.id
}

output "vnet_shared_01_name" {
  value = azurerm_virtual_network.vnet_shared_01.name
}

resource "azurerm_subnet" "vnet_shared_01_subnets" {
  for_each = var.subnets

  name                                           = each.value.name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet_shared_01.name
  address_prefixes                               = [each.value.address_prefix]
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
}

# Dedicated bastion
resource "random_id" "bastion_host_01_name" {
  byte_length = 8
}

resource "azurerm_bastion_host" "bastion_host_01" {
  name                = "bst-${random_id.bastion_host_01_name.hex}-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "ipc-${random_id.bastion_host_01_name.hex}-1"
    subnet_id            = azurerm_subnet.vnet_shared_01_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_host_01.id
  }
}

# Dedicated public ip for bastion
resource "random_id" "public_ip_bastion_host_01_name" {
  byte_length = 8
}

resource "azurerm_public_ip" "bastion_host_01" {
  name                = "pip-${random_id.public_ip_bastion_host_01_name.hex}-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Private DNS zones
resource "azurerm_private_dns_zone" "database_windows_net" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "database_windows_net_to_vnet_shared_01" {
  name                  = "pdnslnk-mssql-to-${azurerm_virtual_network.vnet_shared_01.name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.database_windows_net.name
  virtual_network_id    = azurerm_virtual_network.vnet_shared_01.id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "file_core_windows_net" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags  
}

resource "azurerm_private_dns_zone_virtual_network_link" "file_core_windows_net_to_vnet_shared_01" {
  name                  = "pdnslnk-afs-to-${azurerm_virtual_network.vnet_shared_01.name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.file_core_windows_net.name
  virtual_network_id    = azurerm_virtual_network.vnet_shared_01.id
  registration_enabled  = false
  tags                  = var.tags
}
