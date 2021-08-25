# Shared services virtual network and subnets
resource "azurerm_virtual_network" "vnet_shared_01" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  dns_servers         = [var.dns_server, "168.63.129.16"]
  tags                = var.tags
}

resource "azurerm_subnet" "vnet_shared_01_subnets" {
  for_each = var.subnets

  name                                           = each.value.name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet_shared_01.name
  address_prefixes                               = [each.value.address_prefix]
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
}

output "vnet_shared_01_default_subnet_id" {
  value = azurerm_subnet.vnet_shared_01_subnets["default"].id
}

# Dedicated bastion
resource "random_id" "random_id_bastion_host_01_name" {
  byte_length = 8
}

resource "azurerm_bastion_host" "bastion_host_01" {
  name                = "bst-${random_id.random_id_bastion_host_01_name.hex}-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "ipc-${random_id.random_id_bastion_host_01_name.hex}-1"
    subnet_id            = azurerm_subnet.vnet_shared_01_subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.public_ip_bastion_host_01.id
  }
}

# Dedicated public ip for bastion
resource "random_id" "random_id_public_ip_bastion_host_01_name" {
  byte_length = 8
}

resource "azurerm_public_ip" "public_ip_bastion_host_01" {
  name                = "pip-${random_id.random_id_public_ip_bastion_host_01_name.hex}-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
