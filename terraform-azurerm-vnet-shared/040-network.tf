locals {
  subnets = {
    AzureBastionSubnet = {
      address_prefix                                 = var.subnet_AzureBastionSubnet_address_prefix
      enforce_private_link_endpoint_network_policies = false
      nsgrules = [
        "AllowHttpsInbound",
        "AllowGatewayManagerInbound",
        "AllowAzureLoadBalancerInbound",
        "AllowBastionCommunicationInbound",
        "AllowSshRdpOutbound",
        "AllowAzureCloudOutbound",
        "AllowBastionCommunicationOutbound",
        "AllowGetSessionInformationOutbound"
      ]
    }
    snet-adds-01 = {
      address_prefix                                 = var.subnet_adds_address_prefix
      enforce_private_link_endpoint_network_policies = false
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound",
        "AllowInternetOutbound"
      ]
    }
  }

  nsgrules = {
    AllowAzureCloudOutbound = {
      access                     = "Allow"
      destination_address_prefix = "AzureCloud"
      destination_port_ranges    = ["443"]
      direction                  = "Outbound"
      protocol                   = "TCP"
      source_address_prefix      = "*"
      source_port_ranges         = ["*"]
    }

    AllowAzureLoadBalancerInbound = {
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      protocol                   = "Tcp"
      source_address_prefix      = "AzureLoadBalancer"
      source_port_ranges         = ["*"]
    }

    AllowBastionCommunicationInbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["8080", "5701"]
      direction                  = "Inbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_ranges         = ["*"]
    }

    AllowBastionCommunicationOutbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["8080", "5701"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_ranges         = ["*"]
    }

    AllowGetSessionInformationOutbound = {
      access                     = "Allow"
      destination_address_prefix = "Internet"
      destination_port_ranges    = ["80"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_ranges         = ["*"]
    }

    AllowGatewayManagerInbound = {
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      protocol                   = "Tcp"
      source_address_prefix      = "GatewayManager"
      source_port_ranges         = ["*"]
    }

    AllowHttpsInbound = {
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      protocol                   = "Tcp"
      source_address_prefix      = "Internet"
      source_port_ranges         = ["*"]
    }

    AllowInternetOutbound = {
      access                     = "Allow"
      destination_address_prefix = "Internet"
      destination_port_ranges    = ["*"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_ranges         = ["*"]
    }

    AllowSshRdpOutbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["22", "3389"]
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

# Shared services virtual network, subnets and network security groups
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
  for_each = local.subnets

  name                                           = each.key
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet_shared_01.name
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
