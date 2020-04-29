resource "azurerm_virtual_wan" "vwan1" {
  name                           = var.vwan_name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  disable_vpn_encryption         = false
  allow_branch_to_branch_traffic = true
  allow_vnet_to_vnet_traffic     = false
  tags                           = var.tags
}

resource "azurerm_virtual_hub" "vwanhub1" {
  name                = var.vwan_hub_name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.vwan1.id
  address_prefix      = var.vwan_hub_address_prefix
  tags                = var.tags
}

# Note filed GitHub issue #6663 for misspelled argument names
# Link: https://github.com/terraform-providers/terraform-provider-azurerm/issues/6663 

resource "azurerm_virtual_hub_connection" "vwanhubconnect1" {
  name                                           = var.vwan_hub_connection_name_1
  virtual_hub_id                                 = azurerm_virtual_hub.vwanhub1.id
  remote_virtual_network_id                      = var.remote_virtual_network_id
  hub_to_vitual_network_traffic_allowed          = true
  vitual_network_to_hub_gateways_traffic_allowed = true
  internet_security_enabled                      = true
}

output "vwan1_id" {
  value = azurerm_virtual_wan.vwan1.id
}

output "vwanhub1_id" {
  value = azurerm_virtual_hub.vwanhub1.id
}

output "vwanhubconnect1_id" {
  value = azurerm_virtual_hub_connection.vwanhubconnect1.id
}
