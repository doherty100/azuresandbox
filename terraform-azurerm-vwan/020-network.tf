# Virtual wan

resource "random_id" "random_id_vwan_01_name" {
  byte_length = 8
}

resource "azurerm_virtual_wan" "vwan_01" {
  name                           = "vwan-${random_id.random_id_vwan_01_name.hex}-01"
  resource_group_name            = var.resource_group_name
  location                       = var.location
  tags                           = var.tags
}

# Virtual wan hub
resource "random_id" "random_id_vwan_01_hub_01_name" {
  byte_length = 8
}

resource "azurerm_virtual_hub" "vwan_01_hub_01" {
  name                = "vhub-${random_id.random_id_vwan_01_hub_01_name.hex}-01"
  resource_group_name = azurerm_virtual_wan.vwan_01.resource_group_name
  location            = azurerm_virtual_wan.vwan_01.location
  virtual_wan_id      = azurerm_virtual_wan.vwan_01.id
  address_prefix      = var.vwan_hub_address_prefix
  tags                = var.tags
}

resource "azurerm_virtual_hub_connection" "vwan_01_hub_01_connections" {
  for_each = var.virtual_networks

  name                      = each.key
  virtual_hub_id            = azurerm_virtual_hub.vwan_01_hub_01.id
  remote_virtual_network_id = each.value
}
