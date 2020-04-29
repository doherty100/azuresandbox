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

# Note filed GitHub issue #6663 for misspelled argument names "hub_to_vitual_network_traffic_allowed" and "vitual_network_to_hub_gateways_traffic_allowed"
# Link: https://github.com/terraform-providers/terraform-provider-azurerm/issues/6663 

# Note filed GitHub issue #6694 for InternalServerError when provisioning multiple azurerm_virtual_hub_connection resources using for_each
# Link: https://github.com/terraform-providers/terraform-provider-azurerm/issues/6694 

#  resource "azurerm_virtual_hub_connection" "virtual_hub_connections" {
#   for_each = var.remote_virtual_network_ids

#   name                                           = each.key
#   virtual_hub_id                                 = azurerm_virtual_hub.vwanhub1.id
#   remote_virtual_network_id                      = each.value
#   hub_to_vitual_network_traffic_allowed          = true
#   vitual_network_to_hub_gateways_traffic_allowed = true
#   internet_security_enabled                      = true
# }

output "vwan1_id" {
  value = azurerm_virtual_wan.vwan1.id
}

output "vwanhub1_id" {
  value = azurerm_virtual_hub.vwanhub1.id
}

output "virtual_hub_connection_ids" {
  value = azurerm_virtual_hub_connection.virtual_hub_connections
}