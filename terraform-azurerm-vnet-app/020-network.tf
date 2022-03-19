locals {
  subnets = {
    snet-app-01 = {
      address_prefix                                 = var.subnet_application_address_prefix
      enforce_private_link_endpoint_network_policies = false
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound",
        "AllowInternetOutbound"
      ]
    }
    snet-db-01 = {
      address_prefix                                 = var.subnet_database_address_prefix
      enforce_private_link_endpoint_network_policies = false
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound",
        "AllowInternetOutbound"
      ]
    }
    snet-privatelink-01 = {
      address_prefix                                 = var.subnet_privatelink_address_prefix
      enforce_private_link_endpoint_network_policies = true
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound"
      ]
    }
  }

  nsgrules = {
    AllowInternetOutbound = {
      access                     = "Allow"
      destination_address_prefix = "Internet"
      destination_port_ranges    = ["*"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_ranges         = ["*"]
    }

    AllowVirtualNetworkInbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["*"]
      direction                  = "Inbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_ranges         = ["*"]
    }

    AllowVirtualNetworkOutbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["*"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_ranges         = ["*"]
    }
  }

  network_security_group_rules = flatten([
    for subnet_key, subnet in local.subnets : [
      for nsgrule_key in subnet.nsgrules : {
        subnet_name                = subnet_key
        nsgrule_name               = nsgrule_key
        access                     = local.nsgrules[nsgrule_key].access
        destination_address_prefix = local.nsgrules[nsgrule_key].destination_address_prefix
        destination_port_ranges    = local.nsgrules[nsgrule_key].destination_port_ranges
        direction                  = local.nsgrules[nsgrule_key].direction
        priority                   = 100 + (index(subnet.nsgrules, nsgrule_key) * 10)
        protocol                   = local.nsgrules[nsgrule_key].protocol
        source_address_prefix      = local.nsgrules[nsgrule_key].source_address_prefix
        source_port_ranges         = local.nsgrules[nsgrule_key].source_port_ranges
      }
    ]
  ])
}

# Application virtual network, subnets and network security gruops
resource "azurerm_virtual_network" "vnet_app_01" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  dns_servers         = [var.dns_server, "168.63.129.16"]
  tags                = var.tags
}

resource "azurerm_subnet" "vnet_app_01_subnets" {
  for_each = local.subnets

  name                                           = each.key
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet_app_01.name
  address_prefixes                               = [each.value.address_prefix]
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
}

resource "azurerm_network_security_group" "network_security_groups" {
  for_each = local.subnets

  name                = "nsg-${var.vnet_name}.${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "network_security_rules" {
  for_each = {
    for network_security_group_rule in local.network_security_group_rules : "${network_security_group_rule.subnet_name}.${network_security_group_rule.nsgrule_name}" => network_security_group_rule
  }

  access                      = each.value.access
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = length(each.value.destination_port_ranges) == 1 ? each.value.destination_port_ranges[0] : null 
  destination_port_ranges     = length(each.value.destination_port_ranges) > 1 ? each.value.destination_port_ranges : null
  direction                   = each.value.direction
  name                        = each.value.nsgrule_name
  network_security_group_name = "nsg-${var.vnet_name}.${each.value.subnet_name}"
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group_name
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = length(each.value.source_port_ranges) == 1 ? each.value.source_port_ranges[0] : null 
  source_port_ranges          = length(each.value.source_port_ranges) > 1 ? each.value.source_port_ranges : null

  depends_on = [
    azurerm_network_security_group.network_security_groups
  ]
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
  allow_gateway_transit        = true
}
