resource "azurerm_resource_group" "resource_group_01" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

output "resource_group_01_id" {
  value = azurerm_resource_group.resource_group_01.id
}
